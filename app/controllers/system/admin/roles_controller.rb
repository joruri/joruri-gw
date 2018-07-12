class System::Admin::RolesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    return redirect_to system_roles_path if params[:reset]

    @is_dev = System::Role.is_dev?
    @is_admin = System::Role.is_admin?
    return error_auth unless @is_admin || @is_dev

    @role_id = nz(params[:role_id],'0')
    @priv_id = nz(params[:priv_id],'0')

    search_condition

    Page.title = "権限設定"
  end

  def index
    item = System::Role.new
    item.page  params[:page], params[:limit]
    item.search params
    item.and 'priv_name', '!=','developer'
    @items = item.find(:all,
      :include => [:role_name, :group, :user],
      :order => 'system_role_names.sort_no, priv_name, idx, class_id,system_users.code, system_groups.sort_no, system_groups.code')
  end

  def show
    @item = System::Role.find(params[:id])
  end

  def new
    @item = System::Role.new(:class_id => '1', :priv => '1')
  end

  def create
    conv_uidraw_to_uid
    @item = System::Role.new(role_params)

    _create @item, :success_redirect_uri => "/system/roles?#{@qs}"
  end

  def edit
    @item = System::Role.where(:id => params[:id]).first
  end

  def update
    conv_uidraw_to_uid

    @item = System::Role.find(params[:id])
    @item.attributes = role_params

    _update @item, :success_redirect_uri => "/system/roles/#{@item.id}?#{@qs}"
  end

  def destroy
    @item = System::Role.find(params[:id])

    _destroy @item, :success_redirect_uri => "/system/roles?#{@qs}"
  end

  def user_fields
    users = System::User.get_user_select(params[:g_id])
    render text: view_context.options_for_select(users), layout: false
  end

private

  def role_params
    params.require(:item).permit(:role_name_id, :priv_user_id, :idx, :class_id, :gid_raw, :uid_raw, :priv)
  end

  def search_condition
    params[:role_id] = nz(params[:role_id], @role_id)

    qsa = ['role_id' , 'priv_id' , 'role' , 'priv_user']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

  def conv_uidraw_to_uid
    params[:item]['uid'] = ( params[:item]['class_id'] == '1' ? params[:item]['uid_raw'] : params[:item]['gid_raw']) if nz(params[:item]['class_id'],'') != ''
    params[:item]['group_id'] = ( params[:item]['class_id'] == '1' ? params[:item]['gid_raw'] : '') if nz(params[:item]['class_id'],'') != ''
    params[:item].delete 'uid_raw'
    params[:item].delete 'gid_raw'
  end
end
