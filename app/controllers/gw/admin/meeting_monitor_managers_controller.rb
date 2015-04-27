class Gw::Admin::MeetingMonitorManagersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    Page.title = "会議室案内表示　監視者管理"
    @css = %w(/layout/admin/style.css)

    @u_role = Gw::MeetingMonitorManager.is_admin? # GW全体の管理者
    return error_auth unless @u_role

    @model = Gw::MeetingMonitorManager
  end

  def index
    @items = @model.order(manager_user_addr: :asc, updated_at: :asc)
      .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = @model.find(params[:id])
  end

  def new
    @item = @model.new(
      state: 'enabled', 
      manager_group_id: Core.user_group.id
     )
  end

  def create
    @item = @model.new(params[:item])
    _create @item
  end

  def edit
    @item = @model.find(params[:id])
  end

  def update
    @item = @model.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = @model.find(params[:id])
    @item.state          = 'deleted'
    @item.deleted_at     = Time.now
    @item.deleted_user   = Core.user.name
    @item.deleted_group  = Core.user_group.name
    @item.save(validate: false)

    redirect_to url_for(action: :index), notice: "指定の通知先を削除しました。"
  end

  def user_fields
    users = System::User.get_user_select(params[:g_id])
    render text: view_context.options_for_select([['[指定なし]','']] + users), layout: false
  end

  def user_addr_fields
    user = nil
    user = System::User.find_by(id: params[:g_id]) if params[:g_id].present?
    render text: user.try(:email), layout: false
  end
end
