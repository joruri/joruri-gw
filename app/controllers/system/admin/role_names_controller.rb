class System::Admin::RoleNamesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @is_dev = System::Role.is_dev?
    @is_admin = System::Role.is_admin? || @is_dev
    return error_auth unless @is_admin

    search_condition

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
    @item = System::RoleName.new(role_name_params)

    _create @item, :success_redirect_uri => "/system/role_names?#{@qs}"
  end

  def edit
    @item = System::RoleName.where(:id => params[:id]).first
  end

  def update
    @item = System::RoleName.find(params[:id])
    @item.attributes = role_name_params
    _update @item, :success_redirect_uri => "/system/role_names#{@qs}"
  end

  def destroy
    @item = System::RoleName.find(params[:id])

    _destroy @item, :success_redirect_uri => "/system/role_names?#{@qs}"
  end

  def search_condition
    params[:role_id] = nz(params[:role_id], @role_id)

    qsa = ['role_id', 'priv_id', 'role', 'priv_user']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

private

  def role_name_params
    params.require(:item).permit(:display_name, :table_name, :sort_no)
  end

end
