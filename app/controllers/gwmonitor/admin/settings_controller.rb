#encoding:utf-8
class Gwmonitor::Admin::SettingsController < Gw::Controller::Admin::Base

  include System::Controller::Scaffold
  include Gwmonitor::Controller::Systemname

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  layout "admin/template/gwmonitor"

  def pre_dispatch
    Page.title = "照会・回答システム機能設定"
    @system_title = disp_system_name
    @css = ["/_common/themes/gw/css/monitor.css"]
    
    @is_sysadm = System::Model::Role.get(1, Site.user.id ,'gwmonitor', 'admin') ||
      System::Model::Role.get(2, Site.user_group.id ,'gwmonitor', 'admin')
  end

  def index
  end

  private
  def invalidtoken
    return http_error(404)
  end
end
