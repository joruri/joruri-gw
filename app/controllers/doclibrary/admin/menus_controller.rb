class Doclibrary::Admin::MenusController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    Page.title = "書庫"
    @css = ["/_common/themes/gw/css/doclibrary.css"]
    params[:limit] = 100
  end

  def index
    @items = load_items(Doclibrary::Control)

    @admin_items = []
    @admin_items = load_items(Adminlibrary::Control) if Adminlibrary::Control.table_exists?
  end

  private

  def load_items(control_model)
    items = control_model.distinct.where(state: 'public', view_hide: 1)
    items = items.with_readable_role(Core.user) unless control_model.is_sysadm?
    items.order(sort_no: :asc, docslast_updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit])
  end
end
