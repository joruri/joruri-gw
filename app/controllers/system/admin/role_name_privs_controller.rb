class System::Admin::RoleNamePrivsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    return redirect_to system_role_name_privs_path if params[:reset]

    @is_dev = System::Role.is_dev?
    @is_admin = System::Role.is_admin?
    return error_auth unless @is_dev

    Page.title = "機能権限設定"
  end

  def index
    items = System::RoleNamePriv.joins(:priv, :role)
    items = items.where(role_id: params[:role_id]) if params[:role_id].present?
    @items = items.order("system_role_names.sort_no, system_priv_names.sort_no")
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = System::RoleNamePriv.find(params[:id])
  end

  def new
    @item = System::RoleNamePriv.new
  end

  def create
    @item = System::RoleNamePriv.new(params[:item])
    _create @item
  end

  def edit
    @item = System::RoleNamePriv.find(params[:id])
  end

  def update
    @item = System::RoleNamePriv.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = System::RoleNamePriv.find(params[:id])
    _destroy @item
  end

  def getajax
    options = System::Role.new(role_name_id: params[:role_id]).priv_name_options
    render text: view_context.options_for_select(options), layout: false
  end
end
