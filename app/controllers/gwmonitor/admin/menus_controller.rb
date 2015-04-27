class Gwmonitor::Admin::MenusController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwmonitor::Controller::Systemname
  layout "admin/template/gwmonitor"

  def pre_dispatch
    Page.title = "照会・回答システム"
    @system_title = disp_system_name
    @css = ["/_common/themes/gw/css/monitor.css"]
    page_limit_default_setting
  end

  def index
    @items = Gwmonitor::Doc.with_target_user(Core.user)
      .where(state: params[:cond] == 'already' ? %w(public qNA) : %w(draft editing closed))
      .order(expiry_date: :desc, id: :desc)
      .paginate(page: params[:page], per_page: params[:limit])
      .preload(:control)
  end
end
