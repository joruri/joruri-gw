#encoding:utf-8
class Gw::Admin::PrefConfigsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/pref"

  def initialize_scaffold
    @public_uri = "/gw/pref_configs"
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def init_params
    @mode = nz(params[:mode],"pref_executives")
    if @mode == "pref_executives"
      @ret = "executive"
      Page.title = @page_title = "全庁幹部在庁表示管理"
      @role_developer  = Gw::PrefExecutive.is_dev?
      @role_admin      = Gw::PrefExecutive.is_admin?
    else
      @ret = "director"
      Page.title = @page_title = "部課長在庁表示管理"
      @role_developer  = Gw::PrefDirector.is_dev?
      @role_admin      = Gw::PrefDirector.is_admin?
    end
    @u_role = @role_developer || @role_admin
    @state = nz(params[:state],"normal")
    @return_uri = "/gw/pref_#{@ret}_admins"
    @css = %w(/_common/themes/gw/css/admin.css)
  end

  def index
    init_params
    return authentication_error(403) unless @u_role

    item    = Gw::UserProperty.new
    order   = 'name ASC '
    @items  = item.find(:all,:order=>order)
  end
  def show
    init_params
    return authentication_error(403) unless @u_role
    @item = Gw::UserProperty.find(params[:id])
  end

  def new
    init_params
    return authentication_error(403) unless @u_role
    item = Gw::UserProperty.find(:first,
      :conditions=>["name = ? ",@mode])
    if item.blank?
      item = Gw::UserProperty.new
      item.name = @mode
    end
    item.type_name        = "admin"
    item.save
    location = @return_uri
    redirect_to location
  end

  def create
    init_params
    return authentication_error(403) unless @u_role
    @item = Gw::UserProperty.new(params[:item])
    location = @return_uri
    options = {
      :success_redirect_uri=>location
    }
    _create(@item,options)
  end

  def edit
    init_params
    return authentication_error(403) unless @u_role
    @item = Gw::UserProperty.find(params[:id])
  end

  def update
    init_params
    return authentication_error(403) unless @u_role
	
    location = @return_uri
		unless params[:item][:options].blank?
	    @item = Gw::UserProperty.new.find(params[:id])
		  @item.attributes = params[:item]
	    if @item.save
		  else
			  flash[:notice]="保存できませんでした。"
			end
		else
		  flash[:notice]="保存できませんでした。"
		end
    return redirect_to location
  end

  def destroy
    init_params
    return authentication_error(403) unless @u_role
    @item = Gw::UserProperty.new.find(params[:id])
    location = @return_uri
    options = {
      :success_redirect_uri=>location
    }
    _destroy(@item,options)
  end

  def display_change
    init_params
    return authentication_error(403) unless @u_role == true
    item = Gw::UserProperty.find(:first,
      :conditions=>["name = ?",@mode])
    if item.blank?
      item = Gw::UserProperty.new
      item.name        = @mode
      item.type_name   = @state
      item.options     = "在庁表示は現在準備中です。"
    else
      item.type_name = @state
    end
    if item.save
    else
      flase[:notice]="状態の変更に失敗しました。"
    end
      location = @return_uri
      redirect_to location
  end
end
