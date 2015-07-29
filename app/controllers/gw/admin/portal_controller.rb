# encoding: utf-8
class Gw::Admin::PortalController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal"

  def initialize_scaffold
    Page.title = "Joruri Gw ポータル"
  end

  def index
    session[:request_fullpath] = request.fullpath

    @portal_mode = Gw::AdminMode.portal_mode
    @portal_disaster_bbs = Gw::AdminMode.portal_disaster_bbs
  end
end
