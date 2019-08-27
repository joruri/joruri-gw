class Gw::Admin::SchedulePropsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  def pre_dispatch
    return if params[:action] == 'getajax'
    return redirect_to(url_for(action: :index)) if params[:reset]

    Page.title = "施設予約スケジュール"

    @genre = params[:s_genre].to_s.strip.downcase
    raise Gw::ApplicationError, "指定がおかしいです(#{@genre})" if @genre.blank?

    @show_message_header = true
    @cls = params[:cls]

    case @genre
    when "rentcar"
      @title = "レンタカー"
      @s_genre = "?s_genre=rentcar"
      @prop_type = "Gw::PropRentcar"
      @title_line = @title
    when "meetingroom"
      @title = "会議室"
      @s_genre = "?s_genre=meetingroom"
      @prop_type = "Gw::PropMeetingroom"
      @title_line = @title
    when "other"
      @title = "一般施設"
      @s_genre = "?s_genre=other"
      @prop_type = "Gw::PropOther"
    else
      return http_error(404)
    end
    @item_name = @title

    @piece_head_title = '施設予約スケジュール'
    @index_order = 'extra_flag, sort_no, gid, name'
    @css = %w(/_common/themes/gw/css/schedule.css)
    @uid = Gw::Model::Schedule.get_uids(params)[0]
    @gid = nz(params[:gid], Gw::Model::Schedule.get_user(@uid).groups[0].id) rescue Core.user_group.id
    @state_user_or_group = params[:gid].blank? ? :user : :group
    @sp_mode = :prop

    a_qs = []
    a_qs.push "uid=#{params[:uid]}" unless params[:uid].nil?
    a_qs.push "gid=#{params[:gid]}" unless params[:gid].nil?
    a_qs.push "cls=#{@cls}"
    a_qs.push "s_genre=#{@genre}"
    @schedule_move_qs = a_qs.join('&')


    @is_gw_admin = Gw.is_admin_admin?
    @is_pm_admin = @is_gw_admin ? true : Gw::ScheduleProp.is_pm_admin?

    @schedule_settings = Gw::Schedule.load_system_and_user_settings(Core.user)
    @s_other_admin_gid = nz(params[:s_other_admin_gid], "0").to_i

    @hedder2lnk = 7

    @prop_types = Gw::PropType.select(:id, :name).where(state: 'public').order(sort_no: :asc, id: :asc)
    if params[:type_id].present?
      @type_id = params[:type_id]
    else
      @type_id = @prop_types[0].id if @prop_types.present?
    end
  end

  def show
    @line_box = 1
    @st_date = Gw.date8_to_date params[:id]
    @calendar_first_day = @st_date
    @calendar_end_day = @calendar_first_day

    _props
    if @genre != "other"
      @show_flg = true
      @pm_props = true
    else
      if @prop_edit_ids.length > 0 || @prop_read_ids.length > 0
        @show_flg = true
      else
        @show_flg = false
      end
    end

    _schedule_data
    _schedule_day_data
  end

  def show_week
    @line_box = 1
    kd = params['s_date']
    @st_date = kd =~ /[0-9]{8}/ ? Date.strptime(kd, '%Y%m%d') : Date.today
    @calendar_first_day = @st_date
    @calendar_end_day = @calendar_first_day + 6
    @view = "week"

    @prop_gid = Gw::PropOther.where(id: params[:prop_id]).first.gid if !params[:prop_id].blank?
    _props
    if @genre != "other"
      @show_flg = true
      @pm_props = true
    else
      if @prop_edit_ids.length > 0 || @prop_read_ids.length > 0
        @show_flg = true
      else
        @show_flg = false
      end
    end

    _schedule_data
  end

  def show_guard
    @line_box = 1
    @st_date = Gw.date8_to_date params[:s_date]
    @calendar_first_day = @st_date
    @calendar_end_day = @calendar_first_day

    _props
    if @prop_edit_ids.length > 0 || @prop_read_ids.length > 0
      @show_flg = true
    else
      @show_flg = false
    end

    _schedule_data
    _schedule_day_data
  end

  def _schedule_data
    if @prop_ids.blank?
      @schedule_props = []
    else
      @schedule_props = Gw::ScheduleProp.joins(:schedule)
        .scheduled_between(@calendar_first_day, @calendar_end_day)
        .where(prop_id: @prop_ids)
        .where("extra_data is null or extra_data not like '%\"cancelled\":1%'")
        .tap {|sp| break sp.where(prop_type: @prop_type) if @prop_type }
        .order(st_at: :asc, ed_at: :asc, id: :asc)
        .preload_schedule_relations
    end

    @holidays = Gw::Holiday.find_by_range_cache(@calendar_first_day, @calendar_end_day)
  end

  def _schedule_day_data
    @calendar_first_time = 8
    @calendar_end_time = 19
    @schedule_props.each do |sp|
      @calendar_first_time = 0 if sp.st_at.to_date < @st_date
      @calendar_first_time = sp.st_at.hour if sp.st_at.to_date == @st_date && sp.st_at.hour < @calendar_first_time
      @calendar_end_time = 23 if sp.ed_at.to_date > @st_date
      @calendar_end_time = sp.ed_at.hour if sp.ed_at.to_date == @st_date && sp.ed_at.hour > @calendar_end_time
    end

    @calendar_space_time = (@calendar_first_time..@calendar_end_time) # 表示する予定表の「最初の時刻」と「最後の時刻」の範囲

    @col = ((@calendar_space_time.last - @calendar_space_time.first) * 2) + 2

    @header_each ||= @schedule_settings[:header_each] rescue 5
    @header_each = nz(@header_each, 5).to_i
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

  def show_month
    @line_box = 1
    kd = params['s_date']
    @st_date = kd =~ /[0-9]{8}/ ? Date.strptime(kd, '%Y%m%d') : Date.today

    _month_date

    @hedder2lnk = 7
    @view = "month"

    @prop = eval(@prop_type).where(:id => params[:prop_id]).first

    if @prop.delete_state == 1
      @read = false
      @edit = false
    elsif @is_gw_admin
      @read = true
      @edit = true
    elsif @genre != "other"
      @read = true
      @edit = false
    else
      edit = Gw::PropOtherRole.is_edit?(params[:prop_id])
      read = Gw::PropOtherRole.is_read?(params[:prop_id])
      @edit = edit
      @read = edit || read
    end
    @show_flg = @read
    @pm_props = true

    @schedule_props = Gw::ScheduleProp.joins(:schedule)
      .scheduled_between(@calendar_first_day, @calendar_end_day)
      .where(prop_id: params[:prop_id])
      .where("extra_data is null or extra_data not like '%\"cancelled\":1%'")
      .tap {|sp| break sp.where(prop_type: @prop_type) if @prop_type }
      .order(st_at: :asc, ed_at: :asc, id: :asc)
      .preload_schedule_relations

    @holidays = Gw::Holiday.find_by_range_cache(@calendar_first_day, @calendar_end_day)
  end

  def _props
    @props  =  Gw::Model::Schedule.get_props(params, @is_gw_admin, {:s_other_admin_gid=>@s_other_admin_gid, :type_id => @type_id, :s_genre => @genre })
    @prop_ids = @props.map{|x| x.id}

    if @is_gw_admin
      @prop_edit_ids = @prop_ids
      @prop_read_ids = @prop_ids
    else
      if @genre == 'other'
        gids = [0] + Core.user_group.self_and_ancestors.map(&:id)
        @reservable_prop_ids = @props.with_reservable.map(&:id)
        @prop_edit_ids = Gw::PropOtherRole.select(:id, :prop_id)
          .where(prop_id: @reservable_prop_ids, gid: gids, auth: 'edit')
          .map(&:prop_id)
        @prop_read_ids = Gw::PropOtherRole.select(:id, :prop_id)
          .where(prop_id: @prop_ids, gid: gids, auth: 'read')
          .map(&:prop_id)
      else
        @prop_edit_ids = @props.select(&:reservable?).map(&:id)
        @prop_read_ids = @prop_ids
      end
    end
  end

  def getajax
    @item = Gw::ScheduleProp.getajax params
    respond_to do |format|
      format.json { render :json => @item }
    end
  end
end
