class Digitallibrary::Admin::FoldersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/digitallibrary"

  before_action :check_title_readable, only: [:index, :show]
  before_action :check_title_writable, only: [:new, :create, :edit, :update, :destroy]
  before_action :load_parent_folder

  def pre_dispatch
    return redirect_to url_for(action: :index, title_id: params[:title_id], limit: params[:limit], state: params[:state]) if params[:reset]

    @title = Digitallibrary::Control.find(params[:title_id])

    Page.title = @title.title
    initialize_value_set_new_css_dl
  end

  def index
    items = @title.folders.where(parent_id: @parent.id)
    items = items.where(state: 'closed') if params[:state] == 'DRAFT' && @title.is_writable?
    @items = items.order(level_no: :asc, sort_no: :asc, id: :asc)
      .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = @title.folders.find(params[:id])
    _show @item
  end

  def new
    @item = Digitallibrary::Folder.new(
      :state => 'public' ,
      :latest_updated_at => Time.now,
      :parent_id => @parent.id ,
      :chg_parent_id => @parent.id ,
      :title_id => params[:title_id],
      :doc_type => 0 ,
      :level_no => @parent.level_no + 1,
      :section_code => Core.user_group.code,
      :sort_no => Digitallibrary::Doc::MAX_SEQ_NO,
      :order_no => Digitallibrary::Doc::MAX_SEQ_NO,
      :display_order => 100,  #
      :seq_no => Digitallibrary::Doc::MAX_SEQ_NO.to_f
    )
  end

  def create
    @item = Digitallibrary::Folder.new(params[:item])
    @item.latest_updated_at = Time.now
    @item.title_id = @title.id
    @item.parent_id = @item.chg_parent_id
    @item.sort_no = @item.seq_no
    @item.order_no = @item.seq_no
    @item.level_no = @parent.level_no + 1
    @item.doc_type = 0

    str_params = digitallibrary_docs_path(title_id: @title.id)
    str_params += "&cat=#{@item.parent_id}" unless @item.parent_id == 0 unless @item.parent_id.blank?
    _create @item, success_redirect_uri: str_params
  end

  def edit
    @item = @title.folders.find(params[:id])
    return error_auth unless @item.folder_editable?

    @item.section_code = nil if @item.section_code == ''
    @item.section_code = @item.section_code || Core.user_group.code
  end

  def update
    @item = @title.folders.find(params[:id])
    return error_auth unless @item.doc_type == 0
    return error_auth unless @item.folder_editable?

    @item.attributes = params[:item]
    @item.doc_type = 0

    if @item.parent_id != @item.chg_parent_id
      @item.parent_id = @item.chg_parent_id
      @item.seq_no = Digitallibrary::Doc::MAX_SEQ_NO
    end

    str_params = digitallibrary_docs_path({:title_id=>@title.id})
    str_params += "&cat=#{@item.parent_id}" unless @item.parent_id == 0 unless @item.parent_id.blank?
    _update @item, success_redirect_uri: str_params
  end

  def destroy
    @item = @title.folders.find(params[:id])
    return error_auth unless @item.folder_editable?

    @item.destroy

    str_params = digitallibrary_docs_path({:title_id=>@title.id})
    str_params += "&cat=#{@item.parent_id}" unless @item.parent_id == 0 unless @item.parent_id.blank?
    redirect_to  str_params
  end

  private

  def check_title_readable
    return error_auth unless @title.is_readable?
  end

  def check_title_writable
    return error_auth unless @title.is_writable?
  end

  def load_parent_folder
    if params[:cat].blank?
      @parent = @title.folders.root
    else
      @parent = @title.folders.find(params[:cat])
    end
    return http_error(404) if @parent.blank?
  end
end
