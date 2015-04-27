class Gwmonitor::Admin::SettingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwmonitor::Controller::Systemname
  layout "admin/template/gwmonitor"

  def pre_dispatch
    Page.title = "照会・回答システム機能設定"
    @system_title = disp_system_name
    @css = ["/_common/themes/gw/css/monitor.css"]
  end

  def index
  end
end
