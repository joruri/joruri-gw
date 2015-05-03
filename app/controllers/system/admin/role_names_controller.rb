class System::Admin::RoleNamesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @is_dev = System::Role.is_dev?
    @is_admin = System::Role.is_admin?
    return error_auth unless @is_dev

    Page.title = "機能名設定"
  end

  def index
    @items = System::RoleName.order(:sort_no).paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = System::RoleName.find(params[:id])
  end

  def new
    @item = System::RoleName.new
  end

  def create
    @item = System::RoleName.new(params[:item])
    _create @item
  end

  def edit
    @item = System::RoleName.find(params[:id])
  end

  def update
    @item = System::RoleName.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = System::RoleName.find(params[:id])
    _destroy @item
  end
end
