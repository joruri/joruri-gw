class Gw::Admin::MeetingMonitorSettingsController < Gw::Controller::Admin::Base
   include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    Page.title = "会議室案内表示　監視設定"
    @css = %w(/layout/admin/style.css)

    @u_role = Gw::MeetingMonitorSetting.is_admin? # GW全体の管理者
    return error_auth unless @u_role
  end

  def index
    @items = Gw::MeetingMonitorSetting.order(ip_address: :asc, name: :asc).paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = Gw::MeetingMonitorSetting.find(params[:id])
  end

  def new
    @item = Gw::MeetingMonitorSetting.new(
      state: 'off',
      conditions: 'enabled',
      weekday_notice: 'on',
      holiday_notice: 'off',
    )
  end

  def create
    @item = Gw::MeetingMonitorSetting.new(params[:item])
    _create @item
  end

  def edit
    @item = Gw::MeetingMonitorSetting.find(params[:id])
  end

  def update
    @item = Gw::MeetingMonitorSetting.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = Gw::MeetingMonitorSetting.find(params[:id])
    @item.state         = 'off'
    @item.conditions    = 'deleted'
    @item.deleted_at    = Time.now
    @item.deleted_user  = Core.user.name
    @item.deleted_group = Core.user_group.name
    @item.save(validate: false)

    redirect_to url_for(action: :index), notice: "指定の監視設定を削除しました。"
  end

  def switch_monitor
    @item = Gw::MeetingMonitorSetting.find(params[:id])

    @item.state = params[:state] == 'on' ? 'on' : 'off'
    @item.save(validate: false)

    redirect_to url_for(action: :index), notice: "指定の対象の監視を#{@item.state == 'on' ? '開始' : '終了'}しました。"
  end
end
