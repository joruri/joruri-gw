require 'date'
class Gw::Admin::ScheduleSearchBlanksController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/blank"

  def pre_dispatch
    Page.title = "スケジュール空き時間検索"
    @link_box = false

    @title = 'ユーザ'
    @piece_head_title = '空き時間検索'
    @css = %w(/_common/themes/gw/css/schedule.css)
    @sp_mode = :schedule
    @schedule_settings = Gw::Schedule.load_system_and_user_settings(Core.user)

    @is_gw_admin = Gw.is_admin_admin? # GW全体の管理者
    @is_pm_admin = @is_gw_admin ? true : Gw::ScheduleProp.is_pm_admin? # 管財管理者
    @is_pref_admin = Gw::Schedule.is_schedule_pref_admin? # 全庁予定登録権限7


    @all_day = params[:allday].to_i
    @s_date = Date.strptime(params[:st_date], '%Y%m%d') rescue Date.today
    @e_date = Date.strptime(params[:ed_date], '%Y%m%d') rescue Date.today

    st = @all_day == 0 ? params[:st_time] =~ /[0-9]{2}:[0-9]{2}/ ? params[:st_time].split(':') : %w(0, 0) : %w(0, 0)
    @s_time = Time.mktime(@s_date.year, @s_date.month, @s_date.day, st[0], st[1], '0')
    et = @all_day == 0 ? params[:ed_time] =~ /[0-9]{2}:[0-9]{2}/ ? params[:ed_time].split(':') : %w(23, 59) : %w(23, 59)
    @e_time = Time.mktime(@e_date.year, @e_date.month, @e_date.day, et[0], et[1], '0')

    @s_day = Date.strptime(params[:st_day], '%Y%m%d') rescue @s_date
    @e_day = Date.strptime(params[:ed_day], '%Y%m%d') rescue @e_date
    @sdt = Time.mktime(@s_day.year, @s_day.month, @s_day.day, @s_time.hour, @s_time.min, 0)
    @edt = Time.mktime(@e_day.year, @e_day.month, @e_day.day, @e_time.hour, @e_time.min, 0)

    @uids = params[:uids].split(':')

    @st_date = @s_date
    @show_flg  = true
    @users = System::User.where(id: @uids, state: "enabled")
    @format ||= @schedule_settings["week_view_dayhead_format"]
  end

  def show_day
    @view = "day"
    _schedule_data
    _schedule_day_data
    _schedule_user_data
  end

  def show_week
    @view = "week"
    _schedule_data
  end

  def _schedule_data
    @edit = false

    @calendar_first_day = @s_date
    @calendar_end_day = @view == "week" ? @s_date + 6 : @s_date

    @schedules = Gw::Schedule.distinct.joins(:schedule_users).only_main_schedule.with_participant_uids(@uids)
      .scheduled_between(@calendar_first_day, @calendar_end_day).without_todo
      .order(allday: :desc, st_at: :asc, ed_at: :asc, id: :asc)
      .preload_schedule_relations

    @holidays = Gw::Holiday.find_by_range_cache(@calendar_first_day, @calendar_end_day)
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
end
