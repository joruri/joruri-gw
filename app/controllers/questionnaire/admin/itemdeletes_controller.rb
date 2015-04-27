class Questionnaire::Admin::ItemdeletesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  layout "admin/template/admin"

  def pre_dispatch
    check_gw_system_admin
    return error_auth unless @is_sysadm

    Page.title = "アンケート集計システム  削除設定"
    @css = ["/_common/themes/gw/css/circular.css"]
  end

  def index
    @item = Questionnaire::Itemdelete.where(:content_id => 0).first
  end

  def edit
    @item = Questionnaire::Itemdelete.where(:content_id => 0).first_or_create(:limit_date => '1.month')
    return unless @item.blank?
  end

  def update
    @item = Questionnaire::Itemdelete.where(:content_id => 0).first
    return if @item.blank?

    @item.admin_code = Core.user.code
    @item.attributes = params[:item]

    _update @item, :success_redirect_uri=>'/gw/config_settings?c1=1&c2=7'
  end
  
protected
  
  def check_gw_system_admin
    @is_gw_admin = Gw.is_admin_admin?
    @is_sysadm = true if @is_gw_admin == true
    @is_sysadm = Core.user.has_role?('enquete/admin') unless @is_sysadm
    @is_bbsadm = true if @is_sysadm
  end

end
