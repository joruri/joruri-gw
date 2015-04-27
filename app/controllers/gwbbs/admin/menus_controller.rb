class Gwbbs::Admin::MenusController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    Page.title = "掲示板"
    @css = ["/_common/themes/gw/css/bbs.css"]
  end

  def index
    @items = Gwbbs::Control.where(state: 'public', view_hide: 1)
      .tap {|c| break c.with_readable_role(Core.user) unless Gwbbs::Control.is_sysadm? }
      .order(sort_no: :asc, docslast_updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit]).distinct
  end
end
