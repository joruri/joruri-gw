class Gwfaq::Admin::CategoriesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @title = Gwfaq::Control.find(params[:title_id])

    get_category_parent

    Page.title = @title.title
    @css = ["/_common/themes/gw/css/gwfaq.css"]
  end

  def get_category_parent
    if params[:parent_id].blank? || params[:parent_id].blank? == '0'
      @parent = Gwfaq::Category.new(:id => 0, :level_no => 0)
    else
      @parent = Gwfaq::Category.find(params[:parent_id])
    end
  end

  def index
    @items = @title.categories.order(:sort_no, :id).paginate(page: params[:page], per_page: params[:limit])

    if @parent.id.blank?
      @items = @items.where(level_no: 1)
    else
      @items = @items.where(parent_id: @parent.id)
    end

    _index @items
  end

  def show
    @item = @title.categories.find(params[:id])
    _show @item
  end

  def new
    @item = @title.categories.build(
      :state     => 'public',
      :parent_id => @parent.id,
      :sort_no   => 1,
    )
  end

  def create
    @item = @title.categories.build(category_params)
    @item.state = 'public'
    @item.title_id = @title.id
    @item.parent_id = @parent.id
    @item.level_no  = @parent.level_no + 1
    _create @item, :success_redirect_uri => gwfaq_categories_path(title_id: params[:title_id])
  end

  def update
    @item = @title.categories.find(params[:id])
    @item.attributes = category_params
    @item.state = 'public'
    _update @item, :success_redirect_uri => gwfaq_categories_path(title_id: params[:title_id])
  end

  def destroy
    @item = @title.categories.find(params[:id])

    unless @item.is_deletable?
      flash[:notice] = "指定した分類に記事が登録されているため、削除できませんでした。"
      return redirect_to gwfaq_categories_path(title_id: params[:title_id])
    end
    _destroy @item, :success_redirect_uri => gwfaq_categories_path(title_id: params[:title_id])
  end
private

  def category_params
    params.require(:item).permit(:sort_no, :name)
  end


end
