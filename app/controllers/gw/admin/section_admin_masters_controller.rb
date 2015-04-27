class Gw::Admin::SectionAdminMastersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @is_gw_admin = Gw.is_admin_admin?
    return error_auth unless @is_gw_admin

    Page.title = '主管課マスタ一括削除'
  end

  def clear
  end

  def select_clear
    if Gw::SectionAdminMaster.select_clear(params[:func_name])
      flash[:notice] = "#{Gw::SectionAdminMasterFuncName.get_func_name(params[:func_name])}の主管課担当者を一括で削除しました。"
    else
      flash[:notice] = "主管課の対象が選択されていません。"
    end
    redirect_to url_for(:action => :clear)
  end
end
