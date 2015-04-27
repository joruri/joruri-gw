class Doclibrary::Admin::MenusController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    Page.title = "書庫"
    @css = ["/_common/themes/gw/css/doclibrary.css"]
    params[:limit] = 100
  end

  def index
    @items = Doclibrary::Control.where(state: 'public', view_hide: 1)
      .tap {|c| break c.with_readable_role(Core.user) unless Doclibrary::Control.is_sysadm? }
      .order(sort_no: :asc, docslast_updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit]).distinct
  end
end
