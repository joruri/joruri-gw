class Digitallibrary::Admin::MenusController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/digitallibrary.css"]
    Page.title = "電子図書"
  end

  def index
    @items = Digitallibrary::Control.where(state: 'public', view_hide: 1)
      .tap {|c| break c.with_readable_role(Core.user) unless Digitallibrary::Control.is_sysadm? }
      .order(sort_no: :asc, docslast_updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit]).distinct
  end
end
