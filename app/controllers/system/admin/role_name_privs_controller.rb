# encoding: utf-8
class System::Admin::RoleNamePrivsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def initialize_scaffold
    @css = %w(/layout/admin/style.css)
    return redirect_to(system_role_name_privs_path) if params[:reset]
  end

  def index
    init_params
    return authentication_error(403) unless @is_dev
    item = System::RoleNamePriv.new
    item.page  params[:page], params[:limit]
    order = "system_role_names.sort_no, system_priv_names.sort_no"

    if @role_id != '0'
      @items = item.find(:all, :conditions=>"role_id = #{@role_id}", :joins=>[:priv, :role], :order => order)
    else
      @items = item.find(:all, :joins=>[:priv, :role], :order => order)
    end
  end

  def show
    init_params
    return authentication_error(403) unless @is_dev
    @item = System::RoleNamePriv.find(params[:id])
  end

  def new
    init_params
    return authentication_error(403) unless @is_dev
    @item = System::RoleNamePriv.new({
      #:class_id => '1',
      #:priv => '1'
      })
  end

  def create
    init_params
    return authentication_error(403) unless @is_dev
    @item = System::RoleNamePriv.new(params[:item])
    location  = "/system/role_name_privs#{@params_set}"
    options = {
      :success_redirect_uri=>location,
      :notice => '機能権限設定の登録に成功しました。'
      }
    _create(@item, options)
  end

  def edit
    init_params
    return authentication_error(403) unless @is_dev
    @item = System::RoleNamePriv.find_by_id(params[:id])
  end

  def update
    init_params
    return authentication_error(403) unless @is_dev
    @item = System::RoleNamePriv.new.find(params[:id])
    @item.attributes = params[:item]
    location  = "/system/role_name_privs/#{@item.id}#{@params_set}"
    options = {
      :success_redirect_uri =>  location,
      :notice => "機能権限設定の更新に成功しました。"
      }
    _update(@item, options)
  end

  def destroy
    init_params
    return authentication_error(403) unless @is_dev
    @item = System::RoleNamePriv.new.find(params[:id])
    location  = "/system/role_name_privs#{@params_set}"
    options = {
      :success_redirect_uri=>location,
      :notice => "機能権限設定の削除に成功しました。"
      }
    _destroy(@item, options)
  end

  def init_params
    @is_dev = System::Role.is_dev?
    @is_admin = System::Role.is_admin?
    @role_id = nz(params[:role_id],'0')
    @priv_id = nz(params[:priv_id],'0')

    Page.title = "機能権限設定"

    @params_set = System::RoleNamePriv.params_set(params)
  end

  def getajax
    role_id = params['role_id']
    @items = Array.new
    if role_id.blank? || role_id == ""
      @items = {:errors=>'空欄です'}
    else
      _items = System::RoleNamePriv.get_priv_items(role_id)

      _items.each_with_index do |_item, i|
        @items << [1, "",  ""] if i == 0
        @items << [1, _item.priv_id,  Gw.trim(_item.priv.display_name)]
      end
    end
    _show @items
  end
end
