# encoding: utf-8
class System::Admin::RoleNamesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def initialize_scaffold
    @css = %w(/layout/admin/style.css)
  end

  def index
    init_params
    return authentication_error(403) unless @is_dev
    item = System::RoleName.new
    item.page  params[:page], params[:limit]
    @items = item.find(:all, :order => [:sort_no])
  end

  def show
    init_params
    return authentication_error(403) unless @is_dev
    @item = System::RoleName.find(params[:id])
  end

  def new
    init_params
    return authentication_error(403) unless @is_dev
    @item = System::RoleName.new({
      #:class_id => '1',
      #:priv => '1'
      })
  end

  def create
    init_params
    return authentication_error(403) unless @is_dev
    @item = System::RoleName.new(params[:item])
    location = "/system/role_names?#{@qs}"
    options = {
      :success_redirect_uri=>location
      }
    _create(@item,options)
  end

  def edit
    init_params
    return authentication_error(403) unless @is_dev
    @item = System::RoleName.find_by_id(params[:id])
  end

  def update
    init_params
    return authentication_error(403) unless @is_dev
    @item = System::RoleName.new.find(params[:id])
    @item.attributes = params[:item]
    location = "/system/role_names#{@qs}"
    options = {
      :success_redirect_uri=>location
      }
    _update(@item,options)
  end

  def destroy
    init_params
    return authentication_error(403) unless @is_dev
    @item = System::RoleName.new.find(params[:id])
    location = "/system/role_names?#{@qs}"
    options = {
      :success_redirect_uri=>location
      }
    _destroy(@item,options)
  end

  def init_params
    @is_dev = System::Role.is_dev?
    @is_admin = System::Role.is_admin?

    Page.title = "機能名設定"

    search_condition
  end
  def search_condition
    params[:role_id]    = nz(params[:role_id], @role_id)
#    params[:priv_id]    = nz(params[:priv_id], @priv_id)

    qsa = ['role_id' , 'priv_id' , 'role' , 'priv_user']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

end
