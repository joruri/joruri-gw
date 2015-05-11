class Gwboard::Admin::KnowledgeMakersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    return error_auth if !Gwfaq::Control.is_admin? && !Gwqa::Control.is_admin?
    @system = 'gwfaq'
    @css = ["/_common/themes/gw/css/gwfaq.css"]
    Page.title = "質問管理"
  end

  def index
    @faq_items = load_control_items(Gwfaq::Control)
    @qa_items = load_control_items(Gwqa::Control)
  end

  private

  def load_control_items(model)
    items = model.distinct.where(view_hide: (params[:state] == "HIDE" ? 0 : 1))
    items = items.where(state: 'public').with_admin_role(Core.user) unless model.is_sysadm?
    items = items.order(sort_no: :asc, updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit])
  end
end
