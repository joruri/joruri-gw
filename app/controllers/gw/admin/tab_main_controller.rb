class Gw::Admin::TabMainController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/gw_tab_main"

  def pre_dispatch
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def init_params
    @css = %w(/layout/gw-tab-main/style.css /_common/themes/gw/css/portal_common.css)
    @is_gw_admin = Gw.is_admin_admin?
    session[:request_fullpath] = request.fullpath
  end

  def show
    init_params

    @item = Gw::EditTab.where(level_no: 2, published: "opened", tab_keys: params[:id].to_i).order(sort_no: :desc)
      .preload_opened_children.first
    return http_error(404) if @item.blank?
    Page.title = "Joruri Gw #{@item.name}"
  end
end
