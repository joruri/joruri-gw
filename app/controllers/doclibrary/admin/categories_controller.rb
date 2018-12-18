class Doclibrary::Admin::CategoriesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common

  layout "admin/template/doclibrary"

  def pre_dispatch
    @title = Doclibrary::Control.find(params[:title_id])
    Page.title = @title.title
    initialize_value_set
  end

  def index
    item = Doclibrary::Category
    item = item.new
    item.and  :title_id, params[:title_id]
    item.and  :state, 'public'
    item.page  params[:page], params[:limit]
    @items = item.find(:all)

    _index @items
  end

  def show
    @item = Doclibrary::Category.find(params[:id])

    _show @item
  end

  def new
    item = Doclibrary::Category

    @item = item.create({
      :state => 'preparation',
      :title_id => params[:title_id],
      :sort_no    => 0,
    })

  end

  def create
    @item = Doclibrary::Category.new(category_params)
    @item.state = 'public'

    _create @item
  end

  def update
    item = Doclibrary::Category
    @item = item.new.find(params[:id])
    @item.attributes = category_params
    @item.state = 'public'

    _update @item, :success_redirect_uri => @item.item_path
  end

  def destroy
    item = Doclibrary::Category
    @item = item.new.find(params[:id])

    _destroy @item, :success_redirect_uri => @item.item_path
  end

private
  def category_params
    params.require(:item).permit(:filename, :wareki, :nen, :gatsu, :sono)
  end

end