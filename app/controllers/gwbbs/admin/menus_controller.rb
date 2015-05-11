class Gwbbs::Admin::MenusController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    Page.title = "掲示板"
    @css = ["/_common/themes/gw/css/bbs.css"]
  end

  def index
    items = Gwbbs::Control.distinct.where(state: 'public', view_hide: 1)
    items = items.with_readable_role(Core.user) unless Gwbbs::Control.is_sysadm?
    @items = items.order(sort_no: :asc, docslast_updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit])
  end
end
