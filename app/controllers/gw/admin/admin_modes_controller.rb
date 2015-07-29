# encoding: utf-8
class Gw::Admin::AdminModesController  < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def initialize_scaffold
    @is_admin = Gw::AdminMessage.is_admin?( Site.user.id )
    @is_disaster_admin = Gw::AdminMode.is_disaster_admin?( Site.user.id )
    @is_disaster_editor = Gw::AdminMode.is_disaster_editor?( Site.user.id )
    @u_role = @is_admin || @is_disaster_admin || @is_disaster_editor
    return authentication_error(403) unless @u_role

    Page.title = "表示モード切替"
#    @css = %w(/_common/themes/gw/css/admin_settings.css)
  end

  def index
    @item = Gw::AdminMode.portal_mode_type.first
    @bbs_item = Gw::AdminMode.portal_disaster_bbs_type.first
  end

  def new
    if params[:config].blank?
      flash[:notice] = "パラメータ設定が異常です。"
      return redirect_to gw_admin_modes_path
    end

    @item = Gw::AdminMode.new(:class_id => 3, :name => 'portal')
    if params[:config] == "mode"
      @item.options = '2'
      @item.type_name = "mode"
    else
      @item.type_name = "disaster_bbs"
    end
  end

  def create
    @item = Gw::AdminMode.new(params[:item])

    _create @item, :location => gw_admin_modes_path
  end

  def edit
    @item = Gw::AdminMode.find_by_id(params[:id])
    return http_error(404) if @item.blank?
  end

  def update
    @item = Gw::AdminMode.find_by_id(params[:id])
    return http_error(404) if @item.blank?

    @item.attributes = params[:item]

    _update @item, :location => gw_admin_modes_path
  end
end
