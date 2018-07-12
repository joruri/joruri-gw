class System::Admin::ProductsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    return error_auth unless Core.user.has_role?('_admin/admin')

    Page.title = "プロダクト管理"
  end

  def index
    @items = System::Product.order(:sort_no, :id).paginate(page: params[:page], per_page: 30)
  end

  def show
    @item = System::Product.find(params[:id])
  end

  def new
    @item = System::Product.new
  end

  def create
    @item = System::Product.new(product_params)

    _create @item
  end

  def edit
    @item = System::Product.find(params[:id])
  end

  def update
    @item = System::Product.find(params[:id])
    @item.attributes = product_params

    _update @item
  end

  def destroy
    @item = System::Product.find(params[:id])

    _destroy @item
  end

private

  def product_params
    params.require(:item).permit(:name, :product_type, :sort_no, :product_synchro, :sso, :sso_url, :sso_url_mobile)
  end

end
