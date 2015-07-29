# encoding: utf-8
class System::Admin::RoleDevelopersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def initialize_scaffold
    @css = %w(/layout/admin/style.css)
  end

  def index
    init_params
    return authentication_error(403) unless @is_dev
    item = System::Role.new
    item.page  params[:page], params[:limit]
    condition = 'priv_name = "developer"'
    @items = item.find(:all,
      :include => [:role_name, :user, :group],
      :conditions => condition,
      :order => 'system_role_names.sort_no, priv_name, idx, class_id,system_users.code, system_groups.sort_no, system_groups.code')
  end

  def show
    init_params
    return authentication_error(403) unless @is_dev
    @item = System::Role.find(params[:id])
  end

  def new
    init_params
    return authentication_error(403) unless @is_dev
    @item = System::Role.new({
      :class_id => '1',
      :priv => '1'})
  end

  def create
    init_params
    return authentication_error(403) unless @is_dev
    conv_uidraw_to_uid
    @item = System::Role.new(params[:item])
    location = "/system/role_developers"
    options = {
      :success_redirect_uri=>location
      }
    _create(@item,options)
  end

  def edit
    init_params
    return authentication_error(403) unless @is_dev
    @item = System::Role.find_by_id(params[:id])
  end

  def update
    init_params
    return authentication_error(403) unless @is_dev
    conv_uidraw_to_uid
    @item = System::Role.new.find(params[:id])
    @item.attributes = params[:item]
    location = "/system/role_developers/#{@item.id}"
    options = {
      :success_redirect_uri=>location
      }
    _update(@item,options)
  end

  def conv_uidraw_to_uid()
    params[:item]['uid'] = ( params[:item]['class_id'] == '1' ? params[:item]['uid_raw'] : params[:item]['gid_raw']) if nz(params[:item]['class_id'],'') != ''
    params[:item]['group_id'] = ( params[:item]['class_id'] == '1' ? params[:item]['gid_raw'] : '') if nz(params[:item]['class_id'],'') != ''
    params[:item].delete 'uid_raw'
    params[:item].delete 'gid_raw'
  end

  def destroy
    init_params
    return authentication_error(403) unless @is_dev
    @item = System::Role.new.find(params[:id])
    location = "/system/role_developers"
    options = {
      :success_redirect_uri=>location
      }
    _destroy(@item,options)
  end

  def init_params
    @is_dev = System::Role.is_dev?
    @is_admin = System::Role.is_admin?
    Page.title = "開発者権限設定"
  end

end
