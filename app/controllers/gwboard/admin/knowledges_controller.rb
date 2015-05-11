class Gwboard::Admin::KnowledgesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/gwfaq.css", "/_common/themes/gw/css/gwqa.css"]
    Page.title = "質問管理"
  end

  def index
    @faq_items = load_control_items(Gwfaq::Control)
    @qa_items = load_control_items(Gwqa::Control)
  end

  private

  def load_control_items(model)
    items = model.distinct.where(state: 'public', view_hide: 1)
    items = items.with_readable_role(Core.user) unless model.is_sysadm?
    items = items.order(sort_no: :asc, docslast_updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit])
  end
end
