class Gwcircular::Admin::ItemdeletesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/gwcircular"

  def pre_dispatch
    return error_auth unless Core.user.has_role?('_admin/admin')

    Page.title = "回覧板 削除設定"
    @css = ["/_common/themes/gw/css/circular.css"]

    @item = Gwcircular::Itemdelete.where(content_id: 0)
      .first_or_create(admin_code: Core.user.code, limit_date: '1.month')
  end

  def index
  end

  def edit
  end

  def update
    @item.attributes = delete_params
    _update @item, success_redirect_uri: '/gw/config_settings?c1=1&c2=7'
  end

private

  def delete_params
    params.require(:item).permit(:limit_date)
  end

end
