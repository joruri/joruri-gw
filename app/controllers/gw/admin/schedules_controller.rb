class Gw::Admin::SchedulesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  before_action :load_prop_type, only: [:new, :create]

  def pre_dispatch
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    Page.title = "スケジュール"

    @title = 'ユーザー'
    @piece_head_title = 'スケジュール'
    @css = %w(/_common/themes/gw/css/schedule.css)
    @genre = params[:s_genre] || "other"
    @users = Gw::Model::Schedule.get_users(params)
    @user   = @users[0]

    if @user.blank?
      @uid = nz(params[:uid], Core.user.id).to_i
      @uids = [@uid]
    else
      @uid    = @user.id
      @uids = @users.collect {|x| x.id}
    end
    @gid = nz(params[:gid], @user.groups[0].id).to_i rescue Core.user_group.id

    if params[:cgid].blank? && @gid != 'me'
      x = System::CustomGroup.get_my_view( {:is_default=>1,:first=>1})
      if x.present?
        @cgid = x.id
      end
    else
      @cgid = params[:cgid]
    end

    @first_custom_group = System::CustomGroup.get_my_view( {:sort_prefix => Core.user.code,:first=>1})
    @ucode = Core.user.code
    @gcode = Core.user_group.code

    @state_user_or_group = params[:cgid].blank? ? ( params[:gid].blank? ? :user : :group ) : :custom_group
    @sp_mode = :schedule

    @group_selected = ( params[:cgid].blank? ? '' : 'custom_group_'+params[:cgid] )

    a_qs = []
    a_qs.push "uid=#{params[:uid]}" unless params[:uid].nil?
    a_qs.push "gid=#{params[:gid]}" unless params[:gid].nil? && !params[:cgid].nil?
    a_qs.push "cgid=#{params[:cgid]}" unless params[:cgid].nil? && !params[:gid].nil?
    a_qs.push "todo=#{params[:todo]}" unless params[:todo].nil?
    @schedule_move_qs = a_qs.join('&')

    @is_gw_admin = Gw.is_admin_admin?
    @is_pm_admin = @is_gw_admin ? true : Gw::ScheduleProp.is_pm_admin?
    #@is_pref_admin = Gw::Schedule.is_schedule_pref_admin?

    if params[:cgid].present?
      @custom_group = System::CustomGroup.where(id: params[:cgid]).first
      if @custom_group.present?
        Page.title = "#{@custom_group.name} - スケジュール"
      end
    end

    @schedule_settings = Gw::Schedule.load_system_and_user_settings(Core.user)

    @topdate = nz(params[:topdate]||Time.now.strftime('%Y%m%d'))
    @dis = nz(params[:dis],'week')


    @show_flg = true

    @params_set = Gw::Schedule.params_set(params.dup)
    @ref = Gw::Schedule.get_ref(params.dup)
    @link_params = Gw.a_to_qs(["gid=#{params[:gid]}", "uid=#{nz(params[:uid], Core.user.id)}", "cgid=#{params[:cgid]}"],{:no_entity=>true})

    @hedder2lnk = 1
    @link_format = "%Y%m%d"

    @prop_types = Gw::PropType.select(:id, :name).where(state: 'public').order(sort_no: :asc, id: :asc)
    @todo_display = Gw::Property::TodoSetting.todos_display?

    @link_box = true
  end

  def index
    @line_box = 1
    @st_date = Gw.date8_to_date params[:s_date]
    @calendar_first_day = @st_date
    @calendar_end_day = @calendar_first_day + 6

    @hedder3lnk = 2
    @view = "week"

    if @users.length > 0
      @show_flg = true
    else
      @show_flg = false
    end

    _schedule_data
  end

  def show
    @line_box = 1
    @st_date = Gw.date8_to_date params[:id]
    @calendar_first_day = @st_date
    @calendar_end_day = @calendar_first_day

    @view = "day"

    if @users.length > 0
      @show_flg = true
    else
      @show_flg = false
    end

    _schedule_data
    _schedule_day_data
    _schedule_user_data
  end

  def show_month
    @line_box = 1
    kd = params[:s_date]
    @st_date = kd =~ /[0-9]{8}/ ? Date.strptime(kd, '%Y%m%d') : Date.today

    _month_date
    @view = "month"
    @read = true

    if @is_gw_admin || params[:cgid].blank? ||
        ( params[:cgid].present? && System::CustomGroupRole.new.editable?( params[:cgid], Core.user_group.id, Core.user.id ) )
      @edit = true
    else
      @edit = false
    end

    _schedule_data
  end

  def _schedule_data
    if @is_gw_admin || params[:cgid].blank? ||
        ( params[:cgid].present? && System::CustomGroupRole.new.editable?( params[:cgid], Core.user_group.id, Core.user.id ) )
      @edit = true
    else
      @edit = false
    end

    @schedules = Gw::Schedule.distinct.joins(:schedule_users).only_main_schedule.with_participant_uids(@uids)
      .scheduled_between(@calendar_first_day, @calendar_end_day)
      .tap {|s| break s.without_todo if !@todo_display || @view == "day" }
      .order(allday: :desc, st_at: :asc, ed_at: :asc, id: :asc)
      .preload_schedule_relations

    @schedules = @schedules.reject {|sche|
      schedule_props = sche.collect_schedule_props
      schedule_props.present? && schedule_props.all?(&:cancelled?)
    }

    @holidays = Gw::Holiday.find_by_range_cache(@calendar_first_day, @calendar_end_day)
  end

  def _month_date
    @month_first_day = @st_date.beginning_of_month
    @month_end_day = @st_date.end_of_month

    @calendar_first_day = @month_first_day - @month_first_day.wday

    setting = Gw::Property::ScheduleSetting.where(uid: Core.user.id).first_or_new
    @calendar_first_day += setting.schedules['month_view_leftest_weekday'].to_i
    @calendar_first_day = @calendar_first_day - 7 if @month_first_day < @calendar_first_day

    @calendar_end_day = @calendar_first_day + 7 * 4 - 1
    while @calendar_end_day < @month_end_day
      @calendar_end_day += 7
    end
  end

  def _schedule_day_data
    @calendar_first_time = 8
    @calendar_end_time = 19
    @schedules.each do |schedule|
      @calendar_first_time = 0 if schedule.st_at.to_date < @st_date
      @calendar_first_time = schedule.st_at.hour if schedule.st_at.to_date == @st_date && schedule.st_at.hour < @calendar_first_time
      @calendar_end_time = 23 if schedule.ed_at.to_date > @st_date
      @calendar_end_time = schedule.ed_at.hour if schedule.ed_at.to_date == @st_date && schedule.ed_at.hour > @calendar_end_time
    end

    @calendar_space_time = (@calendar_first_time..@calendar_end_time) # 表示する予定表の「最初の時刻」と「最後の時刻」の範囲

    @col = ((@calendar_space_time.last - @calendar_space_time.first) * 2) + 2

    @header_each ||= @schedule_settings[:header_each] rescue 5
    @header_each = nz(@header_each, 5).to_i
  end

  def _schedule_user_data
    @user_schedules = Hash::new
    @users.each do |user|
      key = "user_#{user.id}"
      @user_schedules[key] = Hash::new
      @user_schedules[key][:schedules] = Array.new
      @user_schedules[key][:allday_flg] = false
      @user_schedules[key][:allday_cnt] = 0

      @schedules.each do |schedule|
        participant = false
        schedule.schedule_users.each do |schedule_user|
          break if participant
          participant = schedule_user.uid == user.id
        end
        if participant
          @user_schedules[key][:schedules] << schedule
          if schedule.allday == 1 || schedule.allday == 2
            @user_schedules[key][:allday_flg] = true
            @user_schedules[key][:allday_cnt] += 1
          end
        end
      end

      @user_schedules[key][:schedule_len] = @user_schedules[key][:schedules].length

      if @user_schedules[key][:schedule_len] == 0
        @user_schedules[key][:trc] = "scheduleTableBody"
        @user_schedules[key][:row] = 1
      else
        if @user_schedules[key][:allday_flg] == true
          @user_schedules[key][:trc] = "alldayLine"
          @user_schedules[key][:row] = (@user_schedules[key][:schedule_len] * 2) - ((@user_schedules[key][:allday_cnt] * 2) - 1)
        else
          @user_schedules[key][:trc] = "scheduleTableBody categoryBorder"
          @user_schedules[key][:row] = @user_schedules[key][:schedule_len] * 2
        end
      end
    end
  end

  def new
    @item = Gw::Schedule.new(is_public: 1)
    @item.set_tmp_id
    if params[:item].present?
      @item.title = params[:item][:title] if params[:item][:title].present?
      @item.memo = params[:item][:memo] if params[:item][:memo].present?
      if params[:item][:schedule_users_json].present?
        @users_json = params[:item][:schedule_users_json]
      end
    end

    @props_json = make_prop_array([@default_prop].compact).to_json

    if request.mobile? && flash[:mail_to].present?
      @users_json = make_participant_array(flash[:mail_to]).to_json
    end
  end

  def quote
    @quote = true
    edit
  end

  def edit_1
    @item = Gw::Schedule.find(params[:id])
    @item.set_tmp_id
    @auth_level = @item.get_edit_delete_level(is_gw_admin: @is_gw_admin, is_pm_admin: @is_pm_admin)
    return error_auth if @auth_level[:edit_level] != 3

    if params[:sh] == "sh"
      @edit_params = '?sh=sh'
    else
      @edit_params = ''
    end

    if @auth_level.key?(:reason) # 注意書き
      @reason = @auth_level[:reason]
    else
      @reason = ''
    end
    users = []
    @item.schedule_users.each do |user|
      # polymorphic になっていないのを自前で解決
      _name = ''
      if user.class_id == 1
        _name = user.user.display_name if !user.user.blank? && user.user.state == 'enabled'
      else
        group = System::Group.where(:id= > user.uid).first
        _name = group.name if !group.blank? && group.state == 'enabled'
      end
      unless _name.blank?
        name = Gw.trim(_name)
        users.push [user.class_id, user.uid, name]
      end
    end
    @users_json = users.to_json

    if !params[:_method].blank?
      if Gw::Schedule.save_with_rels_part(@item, params)
        flash_notice '予定の編集', true
        redirect_to "/gw/schedules/#{@item.id}/show_one#{@edit_params}"
      else
        respond_to do |format|
          format.html { render :action => "edit_1" }
          format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def edit_2
    @item = Gw::Schedule.find(params[:id])
    @item.set_tmp_id
    @auth_level = @item.get_edit_delete_level(is_gw_admin: @is_gw_admin, is_pm_admin: @is_pm_admin)
    return error_auth if @auth_level[:edit_level] != 4

    if @auth_level.key?(:reason) # 注意書き
      @reason = @auth_level[:reason]
    else
      @reason = ''
    end

    if params[:sh] == "sh"
      @edit_params = '?sh=sh'
    else
      @edit_params = ''
    end

    if !params[:_method].blank?
      if Gw::Schedule.save_with_rels_part(@item, params)
        flash_notice '予定の編集', true
        redirect_to "/gw/schedules/#{@item.id}/show_one#{@edit_params}"
      else
        respond_to do |format|
          format.html { render :action => "edit_2" }
          format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def editlending
    @item = Gw::Schedule.find(params[:id])
    @item.set_tmp_id
    @auth_level = @item.get_edit_delete_level(is_gw_admin: @is_gw_admin, is_pm_admin: @is_pm_admin)
    return error_auth if @auth_level[:edit_level] != 2

    if @auth_level.key?(:reason) # 注意書き
      @reason = @auth_level[:reason]
    else
      @reason = ''
    end

    if params[:sh] == "sh"
      @edit_params = '?sh=sh'
    else
      @edit_params = ''
    end

    if !params[:item].blank?
      if Gw::Schedule.save_with_rels_part(@item, params)
        flash_notice '予定の編集', true
        redirect_to "/gw/schedules/#{@item.id}/show_one#{@edit_params}"
      else
        respond_to do |format|
          format.html { render :action => "editlending" }
          format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def edit
    @item = Gw::Schedule.find(params[:id])
    @item.set_tmp_id
    auth_level = @item.get_edit_delete_level(is_gw_admin: @is_gw_admin, is_pm_admin: @is_pm_admin)
    return error_auth if auth_level[:edit_level] != 1 && !@quote

    users = []
    @item.schedule_users.each do |user|
      _name = ''
      if user.class_id == 1
        _name = user.user.display_name if !user.user.blank? && user.user.state == 'enabled'
      else
        group = System::Group.where("id=#{user.uid}").first
        _name = group.name if !group.blank? && group.state == 'enabled'
      end
      unless _name.blank?
        name = Gw.trim(_name)
        users.push [user.class_id, user.uid, name]
      end
    end

    public_groups = Array.new
    @item.public_roles.each do |public_role|
      next if public_role.class_id == 2 && public_role.group.blank?
      next if public_role.class_id != 2 && public_role.user.blank?
      name = Gw.trim(public_role.class_id == 2 ? public_role.group.name :
          public_role.user.name)
      public_groups.push ["", public_role.uid, name]
    end

    props = @item.schedule_props.map(&:prop).compact
    @props_json = make_prop_array(props).to_json
    @prop_type = props.first.prop_type if props.first

    @users_json = users.to_json
    if request.mobile? && flash[:mail_to].present?
      @users_json = make_participant_array(flash[:mail_to]).to_json
    end

    @public_groups_json = public_groups.to_json
  end

  def show_one
    @line_box = 1
    @item = Gw::Schedule.where(id: params[:id]).eager_load(:schedule_todo, :schedule_users, :schedule_props).first
    return http_error(404) if @item.blank?
    return error_auth unless @item.is_public_auth?(@is_gw_admin)

    @auth_level = @item.get_edit_delete_level(is_gw_admin: @is_gw_admin, is_pm_admin: @is_pm_admin)
  end

  def create
    @item = Gw::Schedule.new
    if request.mobile?
      _params = set_mobile_params params
      _params = reject_no_necessary_params _params
    else
      _params = reject_no_necessary_params params
    end
    if params[:purpose] == "confirm"
      if @item.check_rentcar_duplication(_params, :create) #予約重複確認ロジック
        @tmp_repeat = @item.tmp_repeat
        @schedule_props = @item.tmp_props
        @schedule_users = @item.tmp_schedule_users(_params)
        @public_groups_display = @item.tmp_public_groups(_params)
        render :action => 'confirm'
      else
        render :action => 'new'
      end
    elsif params[:purpose] == "re-entering"
      render :action => 'new'
    else
      if Gw::ScheduleRepeat.save_with_rels_concerning_repeat(@item, _params, :create,{:check_temporaries=>true})
        flash_notice '予定の登録', true
        redirect_url = "/gw/schedules/#{@item.id}/show_one?m=new"
        @item.destroy_rentcar_temporaries
        if request.mobile?
          redirect_url += "&gid=#{params[:gid]}&cgid=#{params[:cgid]}&dis=#{params[:dis]}"
        end
        redirect_to redirect_url
      else
        respond_to do |format|
          format.html { render :action => "new" }
          format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def update
    @item = Gw::Schedule.find(params[:id])

    if request.mobile?
      _params = set_mobile_params params
      _params = reject_no_necessary_params _params
    else
      _params = reject_no_necessary_params params
    end

    if params[:purpose] == "confirm"
      if @item.check_rentcar_duplication(_params, :create) #予約重複確認ロジック
        @tmp_repeat = @item.tmp_repeat
        @schedule_props = @item.tmp_props
        @schedule_users = @item.tmp_schedule_users(_params)
        @public_groups_display = @item.tmp_public_groups(_params)
        render :action => 'confirm'
      else
        render :action => 'new'
      end
    elsif params[:purpose] == "re-entering"
      render :action => 'new'
    else
      if Gw::ScheduleRepeat.save_with_rels_concerning_repeat(@item, _params, :update,{:check_temporaries=>true})
        flash[:notice] = '予定の編集に成功しました。'
        redirect_url = "/gw/schedules/#{@item.id}/show_one?m=edit"
        @item.destroy_rentcar_temporaries
        if request.mobile?
          if @item.schedule_parent_id.blank?
            redirect_url += "?gid=#{params[:gid]}&cgid=#{params[:cgid]}&dis=#{params[:dis]}"
          else
            redirect_url += "&gid=#{params[:gid]}&cgid=#{params[:cgid]}&dis=#{params[:dis]}"
          end
        end
        redirect_to redirect_url
      else
        respond_to do |format|
          format.html { render :action => "edit" }
          format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @item = Gw::Schedule.find(params[:id])
    auth_level = @item.get_edit_delete_level(is_gw_admin: @is_gw_admin, is_pm_admin: @is_pm_admin)
    return error_auth if auth_level[:delete_level] != 1

    location =
      if request.mobile?
        gw_schedules_path(dis: params[:dis], gid: params[:gid], cgid: params[:cgid], s_date: params[:s_date])
      else
        st = @item.st_at.strftime("%Y%m%d")
        if @item.schedule_props.length > 0
          "/gw/schedule_props/show_week?s_date=#{st}&s_genre=#{@genre}"
        else
          "/gw/schedules/show_month?s_date=#{st}"
        end
      end

    _destroy @item, success_redirect_uri: location
  end

  def destroy_repeat
    @item = Gw::Schedule.find(params[:id])
    auth_level = @item.get_edit_delete_level(is_gw_admin: @is_gw_admin, is_pm_admin: @is_pm_admin)
    return error_auth if auth_level[:delete_level] != 1

    Gw::Schedule.transaction do
      Gw::Schedule.where(schedule_repeat_id: @item.repeat.id).each do |schedule|
        if schedule.schedule_todo.present?
          schedule.destroy if schedule.schedule_todo.is_finished == 0
        else
          schedule.destroy unless schedule.schedule_props.any? {|sp| sp.prop_extra_pm_actual.present? }
        end
      end
    end

    redirect_url =
      if request.mobile?
        gw_schedules_path(dis: params[:dis], gid: params[:gid], cgid: params[:cgid], s_date: params[:s_date])
      else
        st = @item.st_at.strftime("%Y%m%d")
        if @item.schedule_props.any? {|sp| sp.prop_type == 'Gw::PropOther' }
          "/gw/schedule_props/show_week?s_date=#{st}&s_genre=#{@genre}"
        else
          "/gw/schedules/show_month?s_date=#{st}"
        end
      end

    flash_notice '繰り返し一括削除', true
    redirect_to redirect_url
  end

  def event_week
    # 週間、月間行事表
    @title_line = "週間行事予定表"
    @line_box = 1
    kd = params['s_date']
    @st_date = kd =~ /[0-9]{8}/ ? Date.strptime(kd, '%Y%m%d') : Date.today
    case @st_date.wday
    when 0
      mon = 7
    else
      mon = @st_date.wday
    end
    @st_date = @st_date - mon + 1
    @calendar_first_day = @st_date
    @calendar_end_day = @calendar_first_day + 6
    #@sc_mode = :schedule
    @sp_mode = :event
    @event_view = :week
    @group_selected = "event_week"
    @is_ev_admin = Gw::ScheduleEvent.is_ev_admin?                   # 月間・週刊行事予定の管理者。ロールで設定。
    @is_csv_put_user = Gw::ScheduleEvent.is_csv_put_user?           # CSV出力権限
    @view = "month"
    @show_flg = true
    @event_week = true

    @todo_display = false

    @schedule_events = Gw::ScheduleEvent.joins(:schedule).eager_load(:group)
      .with_week_opened.start_at_between(@calendar_first_day, @calendar_end_day)
      .order("system_groups.sort_no, system_groups.code, gw_schedules.allday DESC, gw_schedules.st_at, gw_schedules.ed_at, gw_schedules.id")
      .preload(:schedule => {:schedule_users => :user, :schedule_props => :prop})

    @groups = Gw::ScheduleEvent.make_groups_from_events(@schedule_events)

    if params[:format] == 'csv' && (@is_ev_admin || @is_csv_put_user)
      csv = Gw::ScheduleEvent.generate_week_csv(@schedule_events, @groups, @calendar_first_day, @calendar_end_day)
      return send_data NKF::nkf('-s', csv), filename: "event_week_#{@calendar_first_day.strftime('%Y%m%d')}.csv"
    end
  end

  def event_month
    # 週間、月間行事表
    @title_line = "月間行事予定表"
    @line_box = 1
    kd = params['s_date']
    @st_date = kd =~ /[0-9]{8}/ ? Date.strptime(kd, '%Y%m%d') : Date.today
    @st_date = Date::new(@st_date.year, @st_date.month, 1)
    @ed_date = @st_date.end_of_month
    #@sc_mode = :schedule
    @egid = nz(params[:egid], Core.user_group.id)
    @egroup = Gw::Model::Schedule.get_group(:gid=>@egid)
    @sp_mode = :event
    @event_view = :month
    @group_selected = "event_month"
    @is_ev_admin = Gw::ScheduleEvent.is_ev_admin?                   # 月間・週刊行事予定の管理者。ロールで設定。
    @is_csv_put_user = Gw::ScheduleEvent.is_csv_put_user?           # CSV出力権限
    @show_flg = true

    @schedule_events =  Gw::ScheduleEvent.joins(:schedule).eager_load(:group)
      .with_month_opened.start_at_between(@st_date, @ed_date)
      .order('system_groups.level_no, system_groups.sort_no, system_groups.code, gw_schedule_events.sort_id, gw_schedules.allday desc, gw_schedule_events.st_at')
      .preload(:schedule)

    if params[:format] == 'csv' && (@is_ev_admin || @is_csv_put_user)
      csv = Gw::ScheduleEvent.generate_month_csv(@schedule_events, @st_date, @ed_date)
      return send_data NKF::nkf('-s', csv), :filename => "event_month_#{@st_date.strftime('%Y%m')}.csv"
    end
  end

  def setting
  end

  def setting_ind
  end

  def setting_ind_schedules
    @item = Gw::Property::ScheduleSetting.where(uid: Core.user.id).first_or_new
  end

  def edit_ind_schedules
    @item = Gw::Property::ScheduleSetting.where(uid: Core.user.id).first_or_new
    @item.options_value = params[:item]

    if @item.save
      flash_notice('スケジューラ設定編集処理', true)
      redirect_to "/gw/schedules/setting_ind"
    else
      render :setting_ind_schedules
    end
  end

  def search
    @group_selected = 'all_group'
    @items = Gwsub.grouplist4(nil, nil, true ,nil , nil, :return_pattern => 1)
    @st_date = Gw.date8_to_date params[:s_date]
  end

  private

  def set_mobile_params(params_i)
    params_o = params_i.dup
    if params_o[:item][:allday] != "1"
      params_o[:item].delete "allday_radio_id"
    end
    st_at_str = %Q(#{params_o[:item]['st_at(1i)']}-#{params_o[:item]['st_at(2i)']}-#{params_o[:item]['st_at(3i)']} #{params_o[:item]['st_at(4i)']}:#{params_o[:item]['st_at(5i)']})
    params_o[:item].delete "st_at(1i)"
    params_o[:item].delete "st_at(2i)"
    params_o[:item].delete "st_at(3i)"
    params_o[:item].delete "st_at(4i)"
    params_o[:item].delete "st_at(5i)"
    params_o[:item][:st_at]= st_at_str
    ed_at_str = %Q(#{params_o[:item]['ed_at(1i)']}-#{params_o[:item]['ed_at(2i)']}-#{params_o[:item]['ed_at(3i)']} #{params_o[:item]['ed_at(4i)']}:#{params_o[:item]['ed_at(5i)']})
    params_o[:item].delete "ed_at(1i)"
    params_o[:item].delete "ed_at(2i)"
    params_o[:item].delete "ed_at(3i)"
    params_o[:item].delete "ed_at(4i)"
    params_o[:item].delete "ed_at(5i)"
    params_o[:item][:ed_at]= ed_at_str
    users_json = []
    if params_o[:item][:schedule_users].blank?
      users_json << ["1",Core.user.id,"#{Core.user.name}"]
    else
      params_o[:item][:schedule_users].each do |u|
        if u[1].to_i != 0
          user_name = System::User.where(:id => u[1]).first
          users_json << ["1",u[1],"#{user_name.name}"]
        end
      end
    end
    params_o[:item][:schedule_users_json] = users_json.to_json
    public_groups_json = []
    if params_o[:item][:public_groups].blank?
      public_groups_json << ["1",Core.user_group.id,"#{Core.user_group.name}"]
    else
      params_o[:item][:public_groups][:gid] = Core.user_group.parent_id
      params_o[:item][:public_groups].each do |g|
        if g[1].to_i != 0
          group_name = System::Group.where(:id => g[1]).first
          public_groups_json << ["1",g[1],"#{group_name.name}"]
        end
      end
    end
    params_o[:item][:public_groups_json] = public_groups_json.to_json
    params_o[:init][:public_groups_json] = public_groups_json.to_json
    return params_o
  end

  def reject_no_necessary_params(params_i)
    params_o = params_i.dup

    params_o[:item].reject!{|k,v| /^(owner_udisplayname)$/ =~ k}
    case params_o[:init][:repeat_mode]
    when "1"
      params_o[:item].reject!{|k,v| /^(repeat_.+)$/ =~ k}
    when "2"
      params_o[:item].delete :st_at
      params_o[:item].delete :ed_at
      params_o[:item][:repeat_weekday_ids] = Gw.checkbox_to_string(params_o[:item][:repeat_weekday_ids])
      params_o[:item][:allday] = params_o[:item][:repeat_allday]
      params_o[:item].delete :repeat_allday
    else
      raise Gw::ApplicationError, "指定がおかしいです(repeat_mode=#{params_o[:init][:repeat_mode]})"
    end
    params_o[:item].reject!{|k,v| /\(\di\)$/ =~ k}
    params_o
  end

  def make_participant_array(uid_str)
    System::User.where(id: uid_str.split(',')).map {|user| [1, user.id, user.name] }
  end

  def make_prop_array(props)
    props.map {|p| [p.genre_name, p.id, p.display_prop_name_for_select] }
  end

  def load_prop_type
    if @genre.present? && params[:prop_id].present?
      @default_prop = Gw::PropBase.load_prop_from_genre(@genre, params[:prop_id])
      @prop_type = @default_prop.prop_type
    end
  end
end
