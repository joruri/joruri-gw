class Gw::Admin::PortalController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal"

  def pre_dispatch
    Page.title = "ポータル"
  end

  def index
    session[:request_fullpath] = request.fullpath

    @portal_mode = Gw::Property::PortalMode.first_or_new
    @portal_disaster_bbs = Gw::Property::PortalDisasterBbs.first_or_new
  end
end
