class Doclibrary::Admin::CategoriesController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Doclibrary::Model::DbnameAlias
  include Gwboard::Controller::Authorize

  layout "admin/template/doclibrary"

  def initialize_scaffold
    @title = Doclibrary::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title
    Page.title = @title.title
    initialize_value_set
  end

  def index
    item = doclib_db_alias(Doclibrary::Category)
    item = item.new
    item.and  :title_id, params[:title_id]
    item.and  :state, 'public'
    item.page  params[:page], params[:limit]
    item.order params[:sort], 'id DESC'
    @items = item.find(:all)
    Doclibrary::Category.remove_connection
    _index @items
  end

  def show
    item = doclib_db_alias(Doclibrary::Category)
    @item = item.new.find(params[:id])
    Doclibrary::Category.remove_connection
    return error_auth unless @item

    item = doclib_db_alias(Doclibrary::File)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, @item.id
    item.order  'id'
    @files = item.find(:all)
    Doclibrary::File.remove_connection
    _show @item
  end

  def new
    item = doclib_db_alias(Doclibrary::Category)

    @item = item.create({
      :state => 'preparation',
      :title_id => params[:title_id],
      :sort_no    => 0,
    })
    Doclibrary::Category.remove_connection
  end

  def update
    item = doclib_db_alias(Doclibrary::Category)
    @item = item.new.find(params[:id])
    @item.attributes = params[:item]
    @item.state = 'public'

    update_creater_editor

    _update @item, :success_redirect_uri => @item.item_path
  end

  def destroy
    item = doclib_db_alias(Doclibrary::Category)
    @item = item.new.find(params[:id])
    
    _destroy @item, :success_redirect_uri => @item.item_path
  end
end