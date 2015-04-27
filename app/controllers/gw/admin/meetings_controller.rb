class Gw::Admin::MeetingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  def pre_dispatch
    Page.title = "会議等案内"
    d = params['s_date']
    @st_date = d =~ /[0-9]{8}/ ? Date.strptime(d, '%Y%m%d') : Date.today
    @sp_mode = :meetings
    @event_view = :month

    @css = %w(/_common/themes/gw/css/schedule.css)

    @users = Gw::Model::Schedule.get_users(params)
    @user   = @users[0]
    @uid    = @user.id if !@user.blank?
    @uid = nz(params[:uid], Core.user.id) if @uid.blank?
    @myuid = Core.user.id
    @gid = nz(params[:gid], @user.groups[0].id) rescue Core.user_group.id
    @mygid = Core.user_group.id

    if params[:cgid].blank? && @gid != 'me'
      x = System::CustomGroup.get_my_view( {:is_default=>1,:first=>1})
      if !x.blank?
        @cgid = x.id
      end
    else
      @cgid = params[:cgid]
    end

    @schedule_settings = Gw::Schedule.load_system_and_user_settings(Core.user)
    @group_selected = "meetings_guide"

    # 権限
    @is_gw_admin = Gw.is_admin_admin? # GW全体の管理者
    @recognizer = Gw::Model::Schedule.meetings_guide_recognizer?
    @meeting_admion = Gw::Model::Schedule.meetings_guide_admin?
    @u_role = @is_gw_admin || @meeting_admion || @recognizer
    @admin_screen_role = params[:mode] == 'admin' && @u_role
  end

  def url_options
    super.merge(params.slice(:page, :mode, :s_date).symbolize_keys) 
  end

  def guide
    return error_auth if params[:mode] == 'admin' && !@u_role

    cond_date = "'#{@st_date.strftime('%Y-%m-%d 0:0:0')}' <= st_at and '#{@st_date.strftime('%Y-%m-%d 23:59:59')}' >= st_at"

    @items = Gw::Schedule.where(cond_date).where(guide_state: [1,2])
      .order(allday: :desc, st_at: :asc, ed_at: :asc, id: :asc)
      .paginate(page: params[:page], per_page: 7)
  end

  def select
    return error_auth unless @u_role

    if params[:ids].blank?
      return redirect_to url_for(action: :guide), notice: "対象が選択されていません。"
    end

    notice = 
      if params[:guide_state_2_submit].present?
        approve_multi
      elsif params[:guide_state_1_submit].present?
        unapprove_multi
      end

    redirect_to url_for(action: :guide), notice: notice
  end

  private

  def approve_multi
    skip = 0
    success = 0
    failure = 0

    Gw::Schedule.where(id: params[:ids]).each do|item|
      if item.guide_state == 1
        if item.approve_meeting_guide
          success += 1
        else
          failure += 1
        end
      else
        skip += 1
      end
    end
  
    notices = []
    if success == 0
      notices << "未承認の案内表示はありませんでした。"
    else
      notices << "#{success}個の案内表示を承認しました。"
    end
    notices << "なお、既に承認済みとなっている案内表示が#{skip}個ありました。" if skip > 0
    notices << "また、#{failure}個の承認に失敗しました。" if failure > 0
    notices.join("<br />")
  end

  def unapprove_multi
    skip = 0
    success = 0
    failure = 0

    Gw::Schedule.where(id: params[:ids]).each do|item|
      if item.guide_state == 2
        if item.unapprove_meeting_guide
          success += 1
        else
          failure += 1
        end
      else
        skip += 1
      end
    end

    notices = []
    if success == 0
      notices << "承認済みの案内表示はありませんでした。"
    else
      notices << "#{success}個の案内表示を承認取消しました。"
    end
    notices << "なお、既に未承認となっている案内表示が#{skip}個ありました。" if skip > 0
    notices << "また、#{failure}個の承認取消に失敗しました。" if failure > 0
    notices.join("<br />")
  end
end
