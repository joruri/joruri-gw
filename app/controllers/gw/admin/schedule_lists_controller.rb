class Gw::Admin::ScheduleListsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  def pre_dispatch
    Page.title = "スケジュール一覧"
    @css = %w(/_common/themes/gw/css/schedule.css)

    @sp_mode = :list

    @user = Core.user
    @list_user = @user
    @uid = Core.user.id

    @list_group = Core.user_group
    @gid = Core.user_group.id

    @today = Date.today

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

    @schedule_settings = Gw::Schedule.load_system_and_user_settings(Core.user)

    @s_year = (params[:s_year].presence || Time.now.year).to_i
    @s_month = params[:s_month].to_i

    case @s_month
    when 0
      @first_day = Time.new(@s_year, 1, 1)
      @end_day = Time.new(@s_year, 12, 31)
    when 100
      @first_day = Time.new(@s_year, Time.now.month, 1)
      @end_day = Time.new(@s_year, 12, 31)
    else
      @first_day = Time.new(@s_year, @s_month, 1)
      @end_day = Time.new(@s_year, @s_month, 1).end_of_month
    end
  end

  def lists
    if params[:uid].present?
      @uid_equal = (params[:uid].to_i == @uid)
      @list_user = System::User.where(:id => params[:uid]).first
      @list_group = @list_user.groups[0]
    else
      @uid_equal = true
    end

    @items = Gw::Schedule.distinct.joins(:schedule_users).scheduled_between(@first_day, @end_day)
      .merge(Gw::ScheduleUser.where(uid: params[:uid].presence || @uid))
      .order(st_at: :asc)
      .preload(:schedule_users => :user)
  end

  def index
    lists
  end

  def csvput
    lists

    csv_data = CSV.generate(:force_quotes => true) do |csv|
      csv << ["件名","開始日","開始時刻","終了日","終了時刻","終日イベント","内容","場所","アラーム オン/オフ","アラーム日付","アラーム時刻"]

      @items.each do |item|
        st_at_day = item.st_at.strftime("%Y-%m-%d")
        ed_at_day = item.ed_at.strftime("%Y-%m-%d")
        if item.allday.blank?
          st_at_time = item.st_at.strftime("%H:%M")
          ed_at_time = item.ed_at.strftime("%H:%M")
          allday = "FALSE"
        else
          st_at_time = "00:00"
          ed_at_time = "23:59"
          allday = "TRUE"
        end
  
        csv << [item.title, st_at_day, st_at_time, ed_at_day, ed_at_time, allday, item.memo, item.place, "", "", ""]
      end
    end

    filename_date = get_filename_date
    send_data NKF::nkf('-Lws', csv_data), type: 'text/csv', filename: "schedule_lists_#{filename_date}.csv"
  end

  def icalput
    lists

    ical = Gw::Controller::Schedule.convert_ical(@items, end_day: @end_day.strftime('%Y-%m-%d'))

    filename_date = get_filename_date
    send_data ical, type: 'text/csv', filename: "schedule_lists_#{filename_date}.ics"
  end

  def user_select
    location = "#{gw_schedule_lists_path}/#{@params_set}"

    if params[:ids].blank?
      return redirect_to location, notice: "対象を選択してください。"
    end

    @target_user = System::User.find_by(id: params[:uid].presence || Core.user.id)

    @items = Gw::Schedule.where(id: params[:ids]).order(st_at: :asc)

    if @items.any? {|item| item.st_at < Time.now }
      return redirect_to location, notice: "過去の予定は変更できません。再度選択してください。" 
    end
  end

  def user_add
    location = "#{gw_schedule_lists_path}/#{@params_set}"

    if params[:cancel].present?
      return redirect_to location
    end

    if params[:ids].blank?
      return redirect_to location, notice: "対象を選択してください。"
    end

    add_user = System::User.find_by(id: params[:add_user_id])

    unless add_user
      return redirect_to location, notice: "ユーザーを選択してください。"
    end

    @items = Gw::Schedule.where(id: params[:ids]).order(st_at: :asc)

    success = 0
    failure = 0
    @items.each do |item|
      if item.schedule_users.all? {|su| su.uid != add_user.id } && 
        (item.is_creator?(Core.user) || item.is_participant?(Core.user) || @is_gw_admin)

        item.updater_uid   = Core.user.id
        item.updater_ucode = Core.user.code
        item.updater_uname = Core.user.name
        item.updater_gid   = Core.user_group.id
        item.updater_gcode = Core.user_group.code
        item.updater_gname = Core.user_group.name
        item.updated_at    = Time.now

        item.schedule_users.build(
          class_id: 1,
          uid: add_user.id,
          created_at: Time.now,
          updated_at: Time.now,
          st_at: item.st_at,
          ed_at: item.ed_at
        )

        item.schedule_props.each do |sp|
          sp.updated_at = Time.now
        end

        if item.save(validate: false)
          success += 1
        else
          failure += 1
        end
      else
        failure += 1
      end
    end

    notices = []
    notices << "#{add_user.display_name}を#{success}件の予定に追加しました。" if success > 0
    notices << "#{failure}件の予定に追加できませんでした。※編集権限がない予定には追加できません。" if failure > 0

    redirect_to location, notice: notices.join('<br />')
  end

  def user_delete
    location = "#{gw_schedule_lists_path}/#{@params_set}"

    if params[:cancel].present?
      return redirect_to location
    end

    if params[:ids].blank?
      return redirect_to location, notice: "対象を選択してください。"
    end

    delete_user = System::User.find_by(id: params[:delete_user_id])

    unless delete_user
      return redirect_to location, notice: "ユーザーを選択してください。"
    end

    @items = Gw::Schedule.where(id: params[:ids]).order(st_at: :asc)

    success = 0
    failure = 0
    @items.each do |item|
      if item.schedule_users.any? {|su| su.uid == delete_user.id } && 
        (item.is_creator?(Core.user) || item.is_participant?(Core.user) || @is_gw_admin)
      
        item.updater_uid   = Core.user.id
        item.updater_ucode = Core.user.code
        item.updater_uname = Core.user.name
        item.updater_gid   = Core.user_group.id
        item.updater_gcode = Core.user_group.code
        item.updater_gname = Core.user_group.name
        item.updated_at    = Time.now

        item.schedule_users.each do |su|
          su.mark_for_destruction if su.uid == delete_user.id
        end

        item.schedule_props.each do |sp|
          sp.updated_at = Time.now
        end

        if item.schedule_users.reject(&:marked_for_destruction?).size > 0 && item.save(validate: false)
          success += 1
        else
          failure += 1
        end
      else
        failure += 1
      end
    end

    notices = []
    notices << "#{delete_user.display_name}を#{success}件の予定から削除しました。" if success > 0
    notices << "#{failure}件の予定からは削除できませんでした。※編集権限がない予定、参加者が１人の予定からは削除できません。" if failure > 0

    redirect_to location, notice: notices.join('<br />')
  end

  def user_fields
    users = System::User.get_user_select(params[:gid])
    render text: view_context.options_for_select(users), layout: false
  end

private

  def get_filename_date
    case @s_month
    when 0
      "#{@first_day.year}_all"
    when 100
      "#{@first_day.year}#{"%02d" % @first_day.month}_after"
    else
      "#{@first_day.year}#{"%02d" % @first_day.month}"
    end
  end
end
