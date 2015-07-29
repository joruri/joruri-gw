# -*- encoding: utf-8 -*-
class Gwsub::Admin::Sb04::Sb04LimitSettingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  layout "admin/template/portal_1column"

  def initialize_scaffold
    @page_title = "電子職員録 管理者設定"
  end

  def init_params
    @is_gw_admin = Gw.is_admin_admin? # GW全体の管理者

    @role_developer  = Gwsub::Sb04stafflist.is_dev?(Site.user.id)
    @role_admin      = Gwsub::Sb04stafflist.is_admin?(Site.user.id)
    @u_role = @role_developer || @role_admin || @is_gw_admin

    @menu_header3 = 'sb04_admin_settings'
    @menu_title3  = '職員録 管理者設定'
    @l1_current = '07'
    
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @public_uri = "/gwsub/sb04/09/sb04_limit_settings"
  end

  def index
    init_params
    return authentication_error(403) unless @u_role == true
    @l2_current = '01'
    item = Gwsub::Sb04LimitSetting.new #.readable
    item.page   params[:page], params[:limit]
    @items = item.find(:all, :conditions => "type_name = 'stafflistview_limit' or type_name = 'divideduties_limit'", :order => "id")
  end

  def show
    init_params
    return authentication_error(403) unless @u_role == true
    @l2_current = '01'
    @item = Gwsub::Sb04LimitSetting.find_by_id(params[:id])
    return http_error(404) if @item.blank?
  end

  def edit
    init_params
    return authentication_error(403) unless @u_role == true
    @l2_current = '01'
    @item = Gwsub::Sb04LimitSetting.find_by_id(params[:id])
    return http_error(404) if @item.blank?
  end

  def update
    init_params
    return authentication_error(403) unless @u_role == true

    @item = Gwsub::Sb04LimitSetting.find_by_id(params[:id])
    return http_error(404) if @item.blank?

    @item.attributes = params[:item]
    options={:location=>"/gwsub/sb04/09/sb04_limit_settings/#{@item.id}"}
    _update(@item,options)
  end

end
