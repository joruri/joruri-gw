class Gwmonitor::Admin::HelpConfigsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwmonitor::Controller::Systemname
  layout "admin/template/gwmonitor"

  def pre_dispatch
    return error_auth unless Gwmonitor::Control.is_sysadm?

    Page.title = "照会・回答システムヘルプ設定"
    @css = ["/_common/themes/gw/css/monitor.css"]
  end

  def index
    @item = Gwmonitor::Property::HelpLink.first_or_new
  end

  def update
    @item = Gwmonitor::Property::HelpLink.first_or_new
    return http_error(404) unless @item

    @item.options_value = params[:item].values
    @item.save
    redirect_to '/gwmonitor/settings'
  end
end
