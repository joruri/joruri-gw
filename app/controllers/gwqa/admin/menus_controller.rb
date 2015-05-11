class Gwqa::Admin::MenusController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/gwfaq.css"]
    Page.title = "質問管理"
  end

  def index
    items = Gwqa::Control.distinct.where(state: 'public', view_hide: 1)
    items = items.with_readable_role(Core.user) unless Gwqa::Control.is_sysadm?
    @items = items.order(sort_no: :asc, docslast_updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit])
  end
end
