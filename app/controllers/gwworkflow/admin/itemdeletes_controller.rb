class Gwworkflow::Admin::ItemdeletesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/gwworkflow"

  def pre_dispatch
    Page.title = "回覧板 削除設定"
    @css = ["/_common/themes/gw/css/workflow.css"]

    check_gw_system_admin
    return error_auth unless @is_sysadm
  end

  def index
    item = Gwworkflow::Itemdelete.new
    item.and :content_id, 0
    @item = item.find(:first)
  end

  def edit
    item = Gwworkflow::Itemdelete.new
    item.and :content_id, 0
    @item = item.find(:first)
    return unless @item.blank?

    @item = Gwworkflow::Itemdelete.create({
      :content_id => 0 ,
      :admin_code => Core.user.code ,
      :limit_date => '1.month'
    })
  end

  def update
    item = Gwworkflow::Itemdelete.new
    item.and :content_id, 0
    @item = item.find(:first)
    return if @item.blank?
    @item.attributes = delete_params
    location = '/gw/config_settings?c1=1&c2=7'
    _update(@item, :success_redirect_uri=>location)
  end

protected

  def check_gw_system_admin
    @is_sysadm = Core.user.has_role?('_admin/admin')
    @is_bbsadm = true if @is_sysadm
  end

private
  def delete_params
    params.require(:item).permit(:limit_date)
  end

end
