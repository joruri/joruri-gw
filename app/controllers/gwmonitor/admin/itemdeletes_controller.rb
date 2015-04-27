class Gwmonitor::Admin::ItemdeletesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwmonitor::Controller::Systemname
  layout "admin/template/gwmonitor"

  def pre_dispatch
    return error_auth unless Gwmonitor::Control.is_sysadm?

    Page.title = "照会・回答システム 削除設定"
    @system_title = disp_system_name
    @css = ["/_common/themes/gw/css/monitor.css"]

    @item = Gwmonitor::Itemdelete.where(content_id: 0)
      .first_or_create(admin_code: Core.user.code, limit_date: '1.month')
  end

  def index
  end

  def edit
  end

  def update
    @item.attributes = params[:item]
    _update @item, success_redirect_uri: '/gw/config_settings?c1=1&c2=7'
  end
end
