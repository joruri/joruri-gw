class System::Admin::RoleDevelopersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @is_dev = System::Role.is_dev?
    @is_admin = System::Role.is_admin?
    return error_auth unless @is_dev

    Page.title = "開発者権限設定"
  end

  def index
    @items = System::Role.includes(:role_name, :user, :group).where(:priv_name => "developer")
      .order('system_role_names.sort_no, priv_name, idx, class_id, system_users.code, system_groups.sort_no, system_groups.code')
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = System::Role.find(params[:id])
  end

  def new
    @item = System::Role.new(:class_id => '1', :priv => '1')
  end

  def create
    conv_uidraw_to_uid
    @item = System::Role.new(params[:item])

    _create @item, :success_redirect_uri => "/system/role_developers"
  end

  def edit
    @item = System::Role.where(:id => params[:id]).first
  end

  def update
    conv_uidraw_to_uid
    @item = System::Role.find(params[:id])
    @item.attributes = params[:item]

    _update @item, :success_redirect_uri => "/system/role_developers/#{@item.id}"
  end

  def destroy
    @item = System::Role.find(params[:id])

    _destroy @item, :success_redirect_uri => "/system/role_developers"
  end

private

  def conv_uidraw_to_uid
    params[:item]['uid'] = ( params[:item]['class_id'] == '1' ? params[:item]['uid_raw'] : params[:item]['gid_raw']) if nz(params[:item]['class_id'],'') != ''
    params[:item]['group_id'] = ( params[:item]['class_id'] == '1' ? params[:item]['gid_raw'] : '') if nz(params[:item]['class_id'],'') != ''
    params[:item].delete 'uid_raw'
    params[:item].delete 'gid_raw'
  end
end
