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
    @item = load_check_item
  end

  def create
    @item = load_check_item
    @item.attributes = params[:item]
    _update @item
  end

  def edit
    @item = load_limit_date_item
  end

  def update
    @item = load_limit_date_item
    @item.attributes = params[:item]
    _update @item
  end

  private

  def load_check_item
    Gwboard::Synthesetup.where(content_id: 0).first_or_create(
      gwbbs_check: false, gwfaq_check: false, gwqa_check: false, doclib_check: false, digitallib_check: false
    )
  end

  def load_limit_date_item
    Gwboard::Synthesetup.where(content_id: 2).first_or_create(limit_date: 'yesterday')
  end
end
