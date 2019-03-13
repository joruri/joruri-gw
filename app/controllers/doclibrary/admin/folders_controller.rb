class Doclibrary::Admin::FoldersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/doclibrary"

  before_action :check_title_readable, only: [:index, :show]
  before_action :check_title_writable, only: [:new, :create, :edit, :update, :destroy]

  def pre_dispatch
    @title = Doclibrary::Control.find(params[:title_id])

    if params[:cat].blank?
      @parent = @title.folders.root
      params[:cat] = @parent.id.to_s
    else
      @parent = @title.folders.find(params[:cat])
    end
    return http_error(404) unless @parent

    Page.title = @title.title
    initialize_value_set
  end

  def index
    @items = @title.folders.where(parent_id: @parent.id).order(:level_no, :sort_no, :id)
      .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = @title.folders.find(params[:id])
    _show @item
  end

  def new
    @item = @title.folders.build(
      :state => @parent.state,
      :parent_id => @parent.id,
      :sort_no => 0,
      :readers => @parent.readers,
      :readers_json => @parent.readers_json,
      :reader_groups => @parent.reader_groups,
      :reader_groups_json => @parent.reader_groups_json
    )
  end

  def create
    @item = @title.folders.build(folder_params)
    @item.parent_id = @parent.id
    @item.level_no = @parent.level_no + 1
    @item.children_size  = 0
    @item.total_children_size = 0

    str_params = doclibrary_docs_path(title_id: @title.id)
    str_params += "&cat=#{@item.parent_id}"
    str_params += "&state=CATEGORY"
    _create @item, success_redirect_uri: str_params
  end

  def edit
    @item = @title.folders.find(params[:id])
  end

  def update
    @item = @title.folders.find(params[:id])
    @item.attributes = folder_params
    str_params = @title.docs_path
    str_params += "&cat=#{@item.parent_id}"
    str_params += "&state=CATEGORY"
    _update @item, success_redirect_uri: str_params
  end

  def destroy
    @item = @title.folders.find(params[:id])

    if @item.destroy
      str_params = doclibrary_docs_path(title_id: @title.id)
      str_params += "&cat=#{@item.parent_id}"
      str_params += "&state=CATEGORY"

      flash[:notice] = '削除処理が完了しました'
      return redirect_to str_params
    else
      flash[:notice] = '削除できません'
      render :action => :show
    end
  end

  private

  def check_title_readable
    return error_auth unless @title.is_readable?
  end

  def check_title_writable
    return error_auth unless @title.is_writable?
  end
private
  def folder_params
    params.require(:item).permit(:state, :use_state, :sort_no, :name,
      :parent_id, :reader_groups_json, :readers_json,
      :reader_groups => [:gid, :uid => []],
      :readers => [:gid, :uid => []])
  end
end
