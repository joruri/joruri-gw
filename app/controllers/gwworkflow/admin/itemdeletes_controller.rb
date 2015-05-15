class Gwworkflow::Admin::ItemdeletesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/gwworkflow"

  def pre_dispatch
    return error_auth unless Core.user.has_role?('_admin/admin')

    Page.title = "ワークフロー削除設定"
    @css = ["/_common/themes/gw/css/workflow.css"]
  end

  def index
    @item = load_itemdelete_item
  end

  def edit
    @item = load_itemdelete_item
  end

  def update
    @item = load_itemdelete_item
    @item.attributes = params[:item]
    _update @item, success_redirect_uri: '/gw/config_settings?c1=1&c2=7'
  end

  private

  def load_itemdelete_item
    Gwworkflow::Itemdelete.where(content_id: 0).first_or_create(
      admin_code: Core.user.code,
      limit_date: '1.month'
    )
  end
end
