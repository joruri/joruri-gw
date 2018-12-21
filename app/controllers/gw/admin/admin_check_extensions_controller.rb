class Gw::Admin::AdminCheckExtensionsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @is_admin = Gw.is_admin_admin?
    return error_auth unless @is_admin

    Page.title = '警告拡張子設定'
  end

  def index
    @items = Gw::AdminCheckExtension.order(state: :asc, sort_no: :asc, updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = Gw::AdminCheckExtension.find(params[:id])
  end

  def new
    @item = Gw::AdminCheckExtension.new(state: 'enabled')
  end

  def create
    @item = Gw::AdminCheckExtension.new(admin_check_params)
    _create @item
  end

  def edit
    @item = Gw::AdminCheckExtension.find(params[:id])
  end

  def update
    @item = Gw::AdminCheckExtension.find(params[:id])
    @item.attributes = admin_check_params
    _update @item
  end

  def destroy
    @item = Gw::AdminCheckExtension.find(params[:id])
    @item.state       = 'deleted'
    @item.deleted_at  = Time.now
    @item.deleted_uid = Core.user.id
    @item.deleted_gid = Core.user_group.id
    @item.save(:validate => false)

    redirect_to url_for(action: :index), notice: "削除処理が完了しました。"
  end

private

  def admin_check_params
    params.require(:item).permit(:state, :extension, :remark, :sort_no)
  end

end
