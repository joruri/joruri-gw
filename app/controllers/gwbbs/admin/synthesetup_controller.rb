class Gwbbs::Admin::SynthesetupController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    return error_auth unless Core.user.has_role?('_admin/admin')

    Page.title = "記事更新情報管理"
    @css = ["/_common/themes/gw/css/bbs.css"]
  end

  def index
  end

  def new
    @item = Gwboard::Synthesetup.where(content_id: 0).first_or_create(
      gwbbs_check: false, gwfaq_check: false, gwqa_check: false, doclib_check: false, digitallib_check: false
    )
  end

  def create
    @item = Gwboard::Synthesetup.where(content_id: 0).first_or_create(
      gwbbs_check: false, gwfaq_check: false, gwqa_check: false, doclib_check: false, digitallib_check: false
    )
    @item.attributes = synthese_params
    _update @item
  end

  def edit
    @item = Gwboard::Synthesetup.where(content_id: 2).first_or_create(limit_date: 'yesterday')
  end

  def update
    @item = Gwboard::Synthesetup.where(content_id: 2).first_or_create(limit_date: 'yesterday')
    @item.attributes = limit_date_params
    _update @item
  end

private
  def synthese_params
    params.require(:item).permit(:gwbbs_check, :gwfaq_check, :gwqa_check, :doclib_check, :digitallib_check)
  end

  def limit_date_params
    params.require(:item).permit(:limit_date)
  end

end
