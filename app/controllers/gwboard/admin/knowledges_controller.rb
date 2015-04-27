class Gwboard::Admin::KnowledgesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/gwfaq.css", "/_common/themes/gw/css/gwqa.css"]
    Page.title = "質問管理"
  end

  def index
    @faq_items = Gwfaq::Control.where(state: 'public', view_hide: 1)
      .tap {|c| break c.with_readable_role(Core.user) unless Gwfaq::Control.is_sysadm? }
      .order(sort_no: :asc, docslast_updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit]).distinct

    @qa_items = Gwqa::Control.where(state: 'public', view_hide: 1)
      .tap {|c| break c.with_readable_role(Core.user) unless Gwqa::Control.is_sysadm? }
      .order(sort_no: :asc, docslast_updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit]).distinct
  end
end
