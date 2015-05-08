class Gwcircular::Admin::CustomGroupsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/gwcircular"

  def pre_dispatch
    params[:title_id] = 1

    @title = Gwcircular::Control.find(params[:title_id])
    return error_auth unless @title.is_readable?

    @css = ["/_common/themes/gw/css/circular.css"]
    params[:limit] = 200
    Page.title = "配信先個人設定"
  end

  def index
    @items = load_index_items
  end

  def show
  end

  def new
    @item = Gwcircular::CustomGroup.new(
      state: 'enabled',
      sort_no: 10
    )
  end

  def create
    @item = Gwcircular::CustomGroup.new(params[:item])
    @item.owner_uid = Core.user.id
    _create @item
  end

  def edit
    @item = Gwcircular::CustomGroup.find(params[:id])
    return error_auth if @item.owner_uid != Core.user.id
  end

  def update
    @item = Gwcircular::CustomGroup.find(params[:id])
    return error_auth if @item.owner_uid != Core.user.id

    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = Gwcircular::CustomGroup.find(params[:id])
    return error_auth if @item.owner_uid != Core.user.id
    _destroy @item
  end

  def sort_update
    @items = load_index_items
    @items.each {|item| item.attributes = params[:items][item.id.to_s] if params[:items][item.id.to_s] }
    _index_update @items
  end

  private

  def load_index_items
    Gwcircular::CustomGroup.where(owner_uid: Core.user.id)
      .order(sort_no: :asc, id: :asc)
      .paginate(page: params[:page], per_page: params[:limit])
  end
end
