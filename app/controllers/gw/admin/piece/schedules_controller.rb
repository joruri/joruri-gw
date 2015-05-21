class Gw::Admin::Piece::SchedulesController < ApplicationController
  include System::Controller::Scaffold
  layout false

  def init_params
    @title = 'ユーザー'
    @piece_head_title = 'スケジュール'
    @css = %w(/_common/themes/gw/css/schedule.css)

    @users = [Core.user]
    @user   = @users[0]

    if @user.blank?
      @uid = nz(params[:uid], Core.user.id)
      @uids = [@uid]
    else
      @uid    = @user.id
      @uids = @users.collect {|x| x.id}
    end
    @gid = nz(params[:gid], @user.groups[0].id) rescue Core.user_group.id

    if params[:cgid].blank? && @gid != 'me'
      x = System::CustomGroup.get_my_view( {:is_default=>1,:first=>1})
      if x.present?
        @cgid = x.id
      end
    else
      @cgid = params[:cgid]
    end
    @sp_mode = :schedule
    @first_custom_group = System::CustomGroup.get_my_view( {:sort_prefix => Core.user.code,:first=>1})
    a_qs = []
    a_qs.push "uid=#{@user.id}"
    a_qs.push "gid=#{params[:gid]}" unless params[:gid].nil? && !params[:cgid].nil?
    a_qs.push "cgid=#{params[:cgid]}" unless params[:cgid].nil? && !params[:gid].nil?
    a_qs.push "todo=#{params[:todo]}" unless params[:todo].nil?
    @schedule_move_qs = a_qs.join('&')

    @is_gw_admin = Gw.is_admin_admin?

    @schedule_settings = Gw::Schedule.load_system_and_user_settings(Core.user)

    @show_flg = true

    @params_set = Gw::Schedule.params_set(params.dup)
    @ref = Gw::Schedule.get_ref(params.dup)
    @link_params = Gw.a_to_qs(["gid=#{params[:gid]}", "uid=#{nz(params[:uid], Core.user.id)}", "cgid=#{params[:cgid]}"],{:no_entity=>true})
    @todo_display = false
    @todo_display = true if @uid == Core.user.id && Gw::Property::TodoSetting.todos_display?
    @hedder2lnk = 1
    @link_format = "%Y%m%d"
    @link_box = true
    @state_user_or_group = :user
  end

  def index
    init_params
    @line_box = 1
    @st_date = Gw.date8_to_date params[:s_date]

    @calendar_first_day = @st_date
    if request.mobile? && !request.smart_phone?
      @calendar_end_day = @calendar_first_day
    else
      @calendar_end_day = @calendar_first_day + 6
    end

    @hedder3lnk = 2
    @view = "week"

    @show_flg = true
    @edit = true

    if @schedule_settings[:view_portal_schedule_display] == '1' || request.smart_phone? || request.mobile?
      @schedules = Gw::Schedule.distinct.joins(:schedule_users).only_main_schedule.with_participant_uids(@uids)
        .scheduled_between(@calendar_first_day, @calendar_end_day)
        .tap {|s| break s.without_todo if !@todo_display }
        .order(allday: :desc, st_at: :asc, ed_at: :asc, id: :asc)
        .preload_schedule_relations

      @schedules = @schedules.reject {|sche|
        schedule_props = sche.collect_schedule_props
        schedule_props.present? && schedule_props.all?(&:cancelled?)
      }

      @holidays = Gw::Holiday.find_by_range_cache(@calendar_first_day, @calendar_end_day)
    else
      render :text => ""
    end
  end
end
