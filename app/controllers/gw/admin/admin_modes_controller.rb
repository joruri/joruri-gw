class Gw::Admin::AdminModesController  < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @is_admin = Gw::AdminMessage.is_admin?
    @is_disaster_admin = Gw::Property::PortalMode.is_disaster_admin?
    @is_disaster_editor = Gw::Property::PortalMode.is_disaster_editor?
    @u_role = @is_admin || @is_disaster_admin || @is_disaster_editor
    return error_auth unless @u_role

    Page.title = "表示モード切替"
#    @css = %w(/_common/themes/gw/css/admin_settings.css)
  end

  def index
    @item = Gw::Property::PortalMode.first_or_new
    @bbs_item = Gw::Property::PortalDisasterBbs.first_or_new
  end

  def edit
    @item = if params[:id] == '0'
        Gw::Property::PortalMode.first_or_new
      else
        Gw::Property::PortalDisasterBbs.first_or_new
      end
  end

  def update
    @item = if params[:id] == '0'
        Gw::Property::PortalMode.first_or_new
      else
        Gw::Property::PortalDisasterBbs.first_or_new
      end
    @item.attributes = mode_params

    _update @item, :location => gw_admin_modes_path
  end

private
  def mode_params
    params.require(:item).permit(:options)
  end

end
