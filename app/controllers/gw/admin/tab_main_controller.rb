# encoding: utf-8
class Gw::Admin::TabMainController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/gw_tab_main"

  def initialize_scaffold
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def init_params
    @css = %w(/layout/gw-tab-main/style.css /_common/themes/gw/css/portal_common.css)
    @is_gw_admin = Gw.is_admin_admin?
    session[:request_fullpath] = request.fullpath
  end

  def show
    init_params
    
    cond  = " level_no=2 and published='opened' and tab_keys=#{params[:id].to_i}"
    order = " sort_no "
    @item = Gw::EditTab.find(:first, :conditions => cond, :order => order, 
      :include => [:parent, 
        :opened_children => [:parent, 
          :opened_children => [:parent]]])
    return http_error(404) if @item.blank?
    
    Page.title = "Joruri Gw #{@item.name}"
  end
end
