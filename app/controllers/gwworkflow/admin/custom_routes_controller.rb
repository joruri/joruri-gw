class Gwworkflow::Admin::CustomRoutesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/gwworkflow"

  def pre_dispatch
    Page.title = "ワークフロー カスタムルート設定"
    @css = ["/_common/themes/gw/css/workflow.css"]
  end

  def index
    @items = load_items
    _index @items
  end

  def new
    @item = Gwworkflow::CustomRoute.new(
      state: 'enabled',
      sort_no: '10',
      owner_uid: Core.user.id
    )
  end

  def create
    @item = Gwworkflow::CustomRoute.new(params[:item])
    @item.owner_uid = Core.user.id
    @item.rebuild_steps_and_committees(params[:committees])

    _create @item
  end

  def edit
    @item = Gwworkflow::CustomRoute.find(params[:id])
    return error_auth if @item.owner_uid != Core.user.id
  end

  def update
    @item = Gwworkflow::CustomRoute.find(params[:id])
    return error_auth if @item.owner_uid != Core.user.id

    @item.attributes = params[:item]
    @item.rebuild_steps_and_committees(params[:committees])

    _update @item
  end

  def destroy
    @item = Gwworkflow::CustomRoute.find(params[:id])
    return error_auth if @item.owner_uid != Core.user.id
    _destroy @item
  end

  def sort_update
    @items = load_items
    @items.each {|item| item.attributes = params[:items][item.id.to_s] if params[:items][item.id.to_s] }
    _index_update @items
  end

private

  def load_items
    Gwworkflow::CustomRoute.where(owner_uid: Core.user.id).order(sort_no: :asc)
      .paginate(page: params[:page], per_page: params[:limit])
  end
end
