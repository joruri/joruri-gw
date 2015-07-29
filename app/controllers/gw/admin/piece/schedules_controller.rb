# encoding: utf-8
class Gw::Admin::Piece::SchedulesController < Gw::Admin::SchedulesController
  include System::Controller::Scaffold
  layout 'base'

  def init_params
    @title = 'ユーザー'
    @piece_head_title = 'スケジュール'
    @js = %w(/_common/js/yui/build/animation/animation-min.js /_common/js/popup_calendar/popup_calendar.js /_common/js/yui/build/calendar/calendar.js /_common/js/dateformat.js)
    @css = %w(/_common/themes/gw/css/schedule.css)

    @users = [Site.user]
    @user   = @users[0]

    if @user.blank?
      @uid = nz(params[:uid], Site.user.id)
      @uids = [@uid]
    else
      @uid    = @user.id
      @uids = @users.collect {|x| x.id}
    end
    @gid = nz(params[:gid], @user.groups[0].id) rescue Site.user_group.id

    if params[:cgid].blank? && @gid != 'me'
      x = System::CustomGroup.get_my_view( {:is_default=>1,:first=>1})
      if x.present?
        @cgid = x.id
      end
    else
      @cgid = params[:cgid]
    end
    @sp_mode = :schedule

    a_qs = []
    a_qs.push "uid=#{@user.id}"
    a_qs.push "gid=#{params[:gid]}" unless params[:gid].nil? && !params[:cgid].nil?
    a_qs.push "cgid=#{params[:cgid]}" unless params[:cgid].nil? && !params[:gid].nil?
    a_qs.push "todo=#{params[:todo]}" unless params[:todo].nil?
    @schedule_move_qs = a_qs.join('&')

    @is_gw_admin = Gw.is_admin_admin?
    @up_schedules = nz(Gw::Model::UserProperty.get('schedules'.singularize), {})

    @schedule_settings = Gw::Model::Schedule.get_settings 'schedules', {}

    @show_flg = true

    @params_set = Gw::Schedule.params_set(params.dup)
    @ref = Gw::Schedule.get_ref(params.dup)
    @link_params = Gw.a_to_qs(["gid=#{params[:gid]}", "uid=#{nz(params[:uid], Site.user.id)}", "cgid=#{params[:cgid]}"],{:no_entity=>true})

    @ie = Gw.ie?(request)
    @hedder2lnk = 1
    @link_format = "%Y%m%d"
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

    if request.smart_phone?
      # スマートフォン
      _schedule_data
    elsif request.mobile?
      # 携帯
      _schedule_data
      _schedule_user_data
    elsif @schedule_settings.present? && @schedule_settings.key?(:view_portal_schedule_display) && 
        nz(@schedule_settings[:view_portal_schedule_display], 1).to_i == 0

      # PC
      render :text => ""

    else
      # PC
      _schedule_data
    end
  end
end
