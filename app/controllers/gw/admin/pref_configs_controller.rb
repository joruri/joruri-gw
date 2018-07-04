class Gw::Admin::PrefConfigsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/pref"

  def pre_dispatch
    init_params
    return error_auth unless @u_role

    @css = %w(/_common/themes/gw/css/admin.css)
  end

  def init_params
    @mode = nz(params[:mode],"executives")
    if @mode == "executives"
      @ret = "executive"
      Page.title = "幹部在庁表示管理"
      @role_developer  = Gw::PrefExecutive.is_dev?
      @role_admin      = Gw::PrefExecutive.is_admin?
    else
      @ret = "director"
      Page.title = "所属幹部在庁表示管理"
      @role_developer  = Gw::PrefDirector.is_dev?
      @role_admin      = Gw::PrefDirector.is_admin?
    end
    @u_role = @role_developer || @role_admin
    @name = nz(params[:name],"normal")
    @return_uri = "/gw/pref_#{@ret}_admins"
  end

  def index
    @items = Gw::PrefConfig.order(:state)
  end

  def show
    @item = Gw::PrefConfig.find(params[:id])
  end

  def new
    item = Gw::PrefConfig.where(:state => "enabled", :option_type => @mode).first_or_create(:name => "admin")

    redirect_to @return_uri
  end

  def create
    @item = Gw::PrefConfig.new(config_params)

    _create @item, :success_redirect_uri => @return_uri
  end

  def edit
    @item = Gw::PrefConfig.find(params[:id])
  end

  def update
    @item = Gw::PrefConfig.find(params[:id])
    @item.attributes = config_params

    _update @item, :success_redirect_uri => @return_uri
  end

  def destroy
    @item = Gw::PrefConfig.find(params[:id])

    _destroy @item, :success_redirect_uri => @return_uri
  end

  def display_change
    @item = Gw::PrefConfig.where(:state => "enabled", :option_type => @mode)
      .first_or_create(:name => @name, :options => "在庁表示は現在準備中です。")
    @item.name = @name

    if @item.save
      flash[:notice] = "状態の変更が完了しました。"
    else
      flash[:notice] = "状態の変更に失敗しました。"
    end
    redirect_to @return_uri
  end

private
  def config_params
    params.require(:item).permit(:options)
  end

end
