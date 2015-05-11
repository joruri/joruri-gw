class Gwqa::Admin::CategoriesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  before_action :load_category_parent

  def pre_dispatch
    @title = Gwqa::Control.find(params[:title_id])

    Page.title = @title.title
    @css = ["/_common/themes/gw/css/gwfaq.css"]
  end

  def index
    items = @title.categories
    items = items.where(level_no: 1) if @parent.id.blank?
    items = items.where(parent_id: @parent.id) if @parent.id.present?
    @items = items.order(sort_no: :asc, id: :asc).paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = @title.categories.find(params[:id])
    _show @item
  end

  def new
    @item = @title.categories.build(
      state: 'public',
      parent_id: @parent.id,
      sort_no: 1,
    )
  end

  def create
    @item = @title.categories.build(params[:item])
    @item.state = 'public'
    @item.title_id = @title.id
    @item.parent_id = @parent.id
    @item.level_no = @parent.level_no + 1
    _create @item, success_redirect_uri: gwqa_categories_path(title_id: params[:title_id])
  end

  def update
    @item = @title.categories.find(params[:id])
    @item.attributes = params[:item]
    @item.state = 'public'
    _update @item, success_redirect_uri: gwqa_categories_path(title_id: params[:title_id])
  end

  def destroy
    @item = @title.categories.find(params[:id])
    unless @item.is_deletable?
      flash[:notice] = "指定した分類に記事が登録されているため、削除できませんでした。"
      return redirect_to gwqa_categories_path(title_id: params[:title_id])
    end
    _destroy @item, success_redirect_uri: gwqa_categories_path(title_id: params[:title_id])
  end

  private

  def load_category_parent
    if params[:parent_id].blank? || params[:parent_id] == '0'
      @parent = Gwqa::Category.new(level_no: 0)
    else
      @parent = Gwqa::Category.find(params[:parent_id])
    end
  end
end
