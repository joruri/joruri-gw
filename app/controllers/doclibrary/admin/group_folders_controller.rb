class Doclibrary::Admin::GroupFoldersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @title = Doclibrary::Control.find(params[:title_id])

    if params[:grp].blank?
      @parent = @title.group_folders.root
    else
      @parent = @title.group_folders.find(params[:grp])
    end

    @css = ["/_common/themes/gw/css/doclibrary.css"]
    Page.title = @title.title
    @cabinet_title = '書庫'
  end

  def index
    @items = @title.group_folders.where(parent_id: @parent.id).order(level_no: :asc, sort_no: :asc, id: :asc)
      .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def new
    @item = @title.group_folders.build(
      :state     => 'closed',
      :use_state => 'public',
      :parent_id => @parent.id,
      :sort_no   => 0
    )
  end

  def create
    @item = @title.group_folders.build(params[:item])
    @item.parent_id = @parent.id
    @item.level_no = @parent.level_no + 1
    @item.state = @parent.try(:state) || 'public'

    _create @item, :success_redirect_uri => url_for(:action => :index, :title_id => @title.id)
  end

  def edit
    @item = @title.group_folders.find(params[:id])
    _show @item
  end

  def update
    @item = @title.group_folders.find(params[:id])
    @item.attributes = params[:item]

    _update @item, :success_redirect_uri => url_for(:action => :index, :title_id => @title.id)
  end

  def destroy
    @item = @title.group_folders.find(params[:id])
    _destroy @item, :success_redirect_uri => url_for(:action => :index, :title_id => @title.id)
  end

  def sync_groups
    @title.group_folders.build.sync_group_folders(params[:mode])

    if params[:make].blank?
      redirect_to doclibrary_group_folders_path(title_id: @title.id)
    else
      redirect_to doclibrary_cabinets_path
    end
  end
end
