# encoding: utf-8
class Gw::Admin::ScheduleListsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  def initialize_scaffold
    Page.title = "スケジュール一覧"
  end

  def init_params
    @js = %w(/_common/js/yui/build/animation/animation-min.js /_common/js/popup_calendar/popup_calendar.js /_common/js/yui/build/calendar/calendar.js /_common/js/dateformat.js)
    @css = %w(/_common/themes/gw/css/schedule.css)

    @db_name = "gw_schedules"
    @sp_mode = :list

    @user = Site.user
    @list_user = @user
    @uid = Site.user.id

    @list_group = Site.user_group
    @gid = Site.user_group.id

    @today = Date.today

    @wdays = ["日", "月", "火", "水", "木", "金", "土"]

    @is_gw_admin = Gw.is_admin_admin?

    if params[:cgid].blank? && @gid != 'me'
      x = System::CustomGroup.get_my_view( {:is_default=>1,:first=>1})
      if x.present?
        @cgid = x.id
      end
    else
      @cgid = params[:cgid]
    end

    @params_set = Gw::ScheduleList.params_set(params.dup)

    kd = params['s_date']
    @st_date = kd =~ /[0-9]{8}/ ? Date.strptime(kd, '%Y%m%d') : Date.today

    @ids_show_flg = params[:action] == 'index'
  end

  def lists
    init_params

    item = Gw::Schedule.new

    now = Time.now

    @s_year = nz(params[:s_year], now.year).to_i
    @s_month = nz(params[:s_month], 0).to_i
    @csv_file_name_date = @st_date

    @uid_equal

    if params[:uid].present?
      @uid_equal = (params[:uid].to_i == @uid)
      @list_user = System::User.find_by_id(params[:uid])
      return http_error(404)  if @list_user.blank?
      uid = params[:uid].to_i
      cond = "gw_schedule_users.uid = #{uid}"
    else
      cond = "gw_schedule_users.uid = #{@uid}"
      @uid_equal = true
    end

    @first_day = "#{@s_year}-01-01"
    @this_month = "#{@s_year}-#{now.month}-01"
    @end_day = "#{@s_year}-12-31"

    if @s_year != 0 && @s_month != 0 && @s_month != 100

      d_1day = Date::new(@s_year, @s_month, 1)
      end_date = d_1day.end_of_month
      @first_day = "#{@s_year}-#{"%02d" % @s_month}-01"
      @end_day = "#{end_date.year}-#{end_date.month}-#{end_date.day}"

      cond += " and #{@db_name}.st_at >= '#{@first_day} 00:00:00'" +
        " and #{@db_name}.st_at <= '#{@end_day} 23:59:59'"

      @csv_file_name_date = "#{@s_year}#{"%02d" % @s_month}01"
    end

    if @s_year != 0 && @s_month == 0
      cond += " and #{@db_name}.st_at >= '#{@first_day} 00:00:00' and #{@db_name}.st_at <= '#{@end_day} 23:59:59'"
      @csv_file_name_date = "#{@s_year}_all"
    end

    if @s_year != 0 && @s_month == 100
      cond += " and #{@db_name}.st_at >= '#{@this_month} 00:00:00' and #{@db_name}.st_at <= '#{@end_day} 23:59:59'"
      @csv_file_name_date = "#{@this_month}_this_month"
    end

    if @s_year == 0 && @s_month != 0
      cond += ""
    end

    @items = item.find(:all, :conditions => cond, :order => "#{@db_name}.st_at",
      :joins => :schedule_users)
  end

  def index
    @list_pattern = :index
    lists
  end

  def csvput
    # CSV出力
    @list_pattern = :csv
    lists

    csv_field = '"件名","開始日","開始時刻","終了日","終了時刻","終日ｲﾍﾞﾝﾄ","内容","場所","ｱﾗｰﾑ ｵﾝ/ｵﾌ","ｱﾗｰﾑ日付","ｱﾗｰﾑ時刻"' + "\n"
    csv = ""
    @items.each_with_index{ | item, cnt |
      st_at = item.st_at
      ed_at = item.ed_at
      title = item.title
      st_at_day = st_at.strftime("%Y-%m-%d")
      ed_at_day = ed_at.strftime("%Y-%m-%d")
      if item.allday.blank?
        st_at_time = st_at.strftime("%H:%M")
        ed_at_time = ed_at.strftime("%H:%M")
        allday = "FALSE"
      else
        ed_at_day = (st_at.to_date + 1).strftime("%Y-%m-%d")
        st_at_time = "00:00"
        ed_at_time = "23:59"
        allday = "TRUE"
      end
      memo = item.memo
      place = item.place

      title = title.gsub('"', '""') unless title.blank?
      memo = memo.gsub('"', '""') unless memo.blank?
      place = place.gsub('"', '""') unless place.blank?

      csv += "\"#{title}\",\"#{st_at_day}\",\"#{st_at_time}\",\"#{ed_at_day}\",\"#{ed_at_time}\",\"#{allday}\",\"#{memo}\",\"#{place}\"," + '"","",""' + "\n"
    }

    if params[:nkf].blank?
      nkf_options = '-Lws'
    else
      nkf_options = case params[:nkf]
      when 'utf8'
        '-w'
      when 'sjis'
        '-Lws'
      end
    end

    filename = "schedule_lists_#{@csv_file_name_date}.csv"
    send_data(NKF::nkf(nkf_options, csv_field + csv), :type => 'text/csv', :filename => filename)
  end

  def icalput
    @list_pattern = :ical
    lists
    options = { :end_day => @end_day }
    ical = Gw::Controller::Schedule.convert_ical( @items , options)
    filename = "schedule_lists_#{@csv_file_name_date}.ics"
    send_data(ical, :type => 'text/csv', :filename => filename)
  end

  def user_select
    init_params
    location = "#{gw_schedule_lists_path}/#{@params_set}"

    if params[:uid].present?
      @target_user = System::User.find_by_id(params[:uid])
    else
      @target_user = System::User.find_by_id(Site.user.id)
    end

    if params[:user_add].present?
      @motion = :user_add
      motion_str = "追加"
    else params[:user_delete].present?
      @motion = :user_delete
      motion_str = "削除"
    end

    if params[:ids].blank?
      flash[:notice] = "対象が選択されていません。"
      redirect_to location
      return
    end

    unless params[:ids].instance_of?(Array)
      flash[:notice] = "#{motion_str}できません。再度、作業を実施してください。"
      redirect_to location
      return
    end

    @ids = params[:ids].dup
    ids_str = Gw.join(params[:ids], ',')
    @items = Gw::Schedule.new.find(:all, :conditions => ["#{@db_name}.id in ( ? )",params[:ids] ], :order => "#{@db_name}.st_at")

    err_array = Array.new

    past = true
    @items.each do |item|
      if item.st_at < Time.now && past == true
        err_array << "過去の予定があります。"
        past = false
      end
    end

    if err_array.length > 0
      err_array << "再度、作業を実施してください。"
      flash[:notice] = Gw.join(err_array, "<br />")
      redirect_to location
      return
    end

  end

  def user_add

    init_params
    location = "#{gw_schedule_lists_path}/#{@params_set}"

    if params[:cancel].present?
      redirect_to location
      return
    end

    if params[:ids].blank?
      flash[:notice] = "対象が選択されていません。"
      redirect_to location
      return
    end

    unless params[:ids].instance_of?(Array)
      flash[:notice] = "追加できません。再度、作業を実施してください。"
      redirect_to location
      return
    end

    if params[:add_user_id].blank?
      flash[:notice] = "追加ユーザーが選択されていませんでした。再度、作業を実施してください。"
      redirect_to location
      return
    end

    @ids = params[:ids].dup
    ids_str = Gw.join(params[:ids], ',')
    add_user = System::User.find_by_id(params[:add_user_id])

    if add_user.blank?
      flash[:notice] = "システムに異常があります。再度、作業を実施してください。"
      redirect_to location
      return
    end

    items = Gw::Schedule.new.find(:all, :conditions => "#{@db_name}.id in (#{ids_str})", :order => "#{@db_name}.st_at")

    up_cnt    = 0
    up_no_cnt = 0
    items.each do |item|

      up = false

      creator = item.creator_uid == Site.user.id

      participation = Gw::ScheduleUser.new.find(:first,
        :conditions => "schedule_id = #{item.id} and class_id = 1 and uid = #{Site.user.id}")

      schedule_user = Gw::ScheduleUser.new.find(:first,
        :conditions => "schedule_id = #{item.id} and class_id = 1 and uid = #{add_user.id}")

      if schedule_user.blank? && (creator || !participation.blank? || @is_gw_admin)
        schedule_user_item = Gw::ScheduleUser.new
        schedule_user_item.schedule_id = item.id
        schedule_user_item.class_id    = 1
        schedule_user_item.uid         = add_user.id
        schedule_user_item.created_at  = Time.now
        schedule_user_item.updated_at  = Time.now
        schedule_user_item.st_at       = item.st_at
        schedule_user_item.ed_at       = item.ed_at
        schedule_user_item.save(:validate => false)

        item.updater_uid   = Site.user.id
        item.updater_ucode = Site.user.code
        item.updater_uname = Site.user.name
        item.updater_gid   = Site.user_group.id
        item.updater_gcode = Site.user_group.code
        item.updater_gname = Site.user_group.name
        item.updated_at    = Time.now
        item.save(:validate => false)

        unless item.schedule_props.blank?
          item.schedule_props.each do |schedule_prop|
            schedule_prop.updated_at = Time.now
            schedule_prop.save(:validate => false)
          end
        end

        up = true

      end

      up_cnt    += 1 if up == true
      up_no_cnt += 1 if up == false
    end

    notice = "ユーザー「#{add_user.display_name}」を#{up_cnt}件の予定に追加しました。"
    if up_no_cnt > 0
      notice += "#{up_no_cnt}件の予定には、追加されませんでした。"
      notice += "<br />※編集権限がない予定はコピーできません。"
    end
    flash[:notice] = notice

    redirect_to location
  end

  def user_delete
    init_params
    location = "#{gw_schedule_lists_path}/#{@params_set}"

    if params[:cancel].present?
      redirect_to location
      return
    end

    if params[:ids].blank?
      flash[:notice] = "対象が選択されていません。"
      redirect_to location
      return
    end

    unless params[:ids].instance_of?(Array)
      flash[:notice] = "削除できません。再度、作業を実施してください。"
      redirect_to location
      return
    end

    if params[:delete_user_id].blank?
      flash[:notice] = "システムに異常があります。管理者に連絡をしてください。"
      redirect_to location
      return
    end

    @ids = params[:ids].dup
    ids_str = Gw.join(params[:ids], ',')
    delete_user = System::User.find_by_id(params[:delete_user_id])

    if delete_user.blank?
      flash[:notice] = "一覧の表示から確認して下さい。"
      redirect_to location
      return
    end

    items = Gw::Schedule.find(:all, :conditions => "#{@db_name}.id in (#{ids_str})", :order => "#{@db_name}.st_at")

    delete_cnt = 0
    delete_no_cnt = 0
    items.each do |item|

      delete = false

      _delete = false
      creator = item.creator_uid == Site.user.id

      participation = Gw::ScheduleUser.new.find(:first,
        :conditions => "schedule_id = #{item.id} and class_id = 1 and uid = #{Site.user.id}")

      if item.schedule_users.blank?
        user_len = 0
      else
        user_len = item.schedule_users.length
      end

      if (creator || !participation.blank? || @is_gw_admin) && user_len > 1

        delete_user_items = Gw::ScheduleUser.new.find(:all,
          :conditions => "schedule_id = #{item.id} and class_id = 1 and uid = #{delete_user.id}", :order => "id")
        delete_user_items.each do | delete_user_item |
          delete_user_item.destroy
          _delete = true
        end

        if _delete == true
          item.updater_uid   = Site.user.id
          item.updater_ucode = Site.user.code
          item.updater_uname = Site.user.name
          item.updater_gid   = Site.user_group.id
          item.updater_gcode = Site.user_group.code
          item.updater_gname = Site.user_group.name
          item.updated_at    = Time.now
          item.save(:validate => false)
          delete = true

          unless item.schedule_props.blank?
            item.schedule_props.each do |schedule_prop|
              schedule_prop.updated_at = Time.now
              schedule_prop.save(:validate => false)
            end
          end

        end
      end

      delete_cnt += 1    if delete == true
      delete_no_cnt += 1 if delete == false
    end

    notice = "ユーザー#{delete_user.display_name}を#{delete_cnt}件の予定から削除しました。"
    if delete_no_cnt > 0
      notice += "#{delete_no_cnt}件の予定からは、削除されませんでした。"
      notice += "<br />※編集権限がない予定は削除できません。<br />※参加者が１人の予定は削除できません。"
    end
    flash[:notice] = notice

    redirect_to location

  end

  def user_fields
    users = System::User.get_user_select(params[:gid], nil)
    html_select = ""
    users.each do |value , key|
      html_select << "<option value='#{key}'>#{value}</option>"
    end

    respond_to do |format|
      format.csv { render :text => html_select ,:layout=>false ,:locals=>{:f=>@item} }
    end
  end
end
