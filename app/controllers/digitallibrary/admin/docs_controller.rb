class Digitallibrary::Admin::DocsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  include Digitallibrary::Admin::DocsHelper
  layout "admin/template/digitallibrary"

  before_action :check_title_readable, only: [:index, :show]
  before_action :check_title_writable, only: [:new, :create, :edit, :update, :destroy]
  before_action :load_parent_folder

  def pre_dispatch
    return redirect_to url_for(action: :index, title_id: params[:title_id], limit: params[:limit], state: params[:state]) if params[:reset]

    @title = Digitallibrary::Control.find(params[:title_id])

    initialize_value_set_new_css_dl

    Page.title = @title.title
    @css = ["/_common/themes/gw/css/#{@title.system_name}_standard.css"]
    if params[:state] == 'DATE'
      @css << "/_common/themes/gw/css/doc_1column_dl.css"
    else
      @css << "/_common/themes/gw/css/doc_2column_dl.css"
    end
  end

  def index
    @items = index_docs.index_select.paginate(page: params[:page], per_page: params[:limit]).preload(:section)
    @items.preload!(:parent) if params[:state] == 'DATE'

    if params[:state] == 'DRAFT'
      items = @title.folders.index_select.where(state: 'closed')
      items = items.group_or_creater_docs unless @title.is_admin?
      @folders = items.order(level_no: :asc, sort_no: :asc, id: :asc)
        .paginate(page: params[:page], per_page: params[:limit])
    end
  end

  def show
    @item = @title.docs.find_by(id: params[:id])
    return find_migrated_item unless @item
    return http_error(404) if @item.state == 'preparation'
    return error_auth if @item.state == 'draft' && !@item.is_editable?
    return error_auth if !@title.is_readable? && !@item.is_recongnizable? && !@item.is_publishable?

    @item.doc_alias = 0 if @item.doc_alias.blank?
    @parent = @item.parent

    Page.title = @item.title

    # 前後記事
    load_next_and_prev_item
  end

  def new
    @item = Digitallibrary::Doc.create(
      :state => 'preparation',
      :latest_updated_at => Time.now,
      :parent_id => @parent.id ,
      :chg_parent_id => @parent.id ,
      :title_id => params[:title_id] ,
      :doc_alias => 0,
      :doc_type => 1,
      :level_no => @parent.level_no + 1,
      :seq_no => Digitallibrary::Doc::MAX_SEQ_NO,
      :order_no => Digitallibrary::Doc::MAX_SEQ_NO.to_i,
      :sort_no => Digitallibrary::Doc::MAX_SEQ_NO.to_i,
      :display_order => 100,
      :section_code => Core.user_group.code,
      :category4_id => 0,
      :category1_id => params[:cat],
      :wiki => 0
    )

    @item.state = 'draft'
  end

  def edit
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_editable?

    @item.section_code = Core.user_group.code if @item.section_code.blank?
    @item.category4_id = 0 if @item.category4_id.blank?
    @item.doc_alias = 0 if @item.doc_alias.blank?
  end

  def update
    @item = @title.docs.find(params[:id])
    @item.attributes = params[:item]

    @item.latest_updated_at = Time.now unless @item.skip_updating_updated_at == '1'
    @item.doc_type = 1
    @item.section_code = Core.user_group.code if @item.section_code.blank?
    @item.section_name  = "#{@item.section_code}#{@item.section.try(:name)}"
    @item.doc_alias = 0 if @item.doc_alias.blank?

    if @item.parent_id != @item.chg_parent_id
      @item.parent_id = @item.chg_parent_id
      @item.seq_no = Digitallibrary::Doc::MAX_SEQ_NO
    end

    _update @item, success_redirect_uri: "#{digitallibrary_docs_path({:title_id=>@title.id})}&state=#{params[:state]}#{digitallib_uri_params}"
  end

  def destroy
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_editable?

    @item.destroy

    str_param = ''
    str_param += "&cat=#{params[:cat]}" unless params[:cat].blank?
    redirect_to "#{digitallibrary_docs_path(:title_id=>@title.id)}#{str_param}"
  end

  def recognize_update
    @item = @title.docs.find(params[:id])

    @item.recognize(Core.user)

    if @title.is_writable?
      redirect_to "#{@title.docs_path}&state=RECOGNIZE"
    else
      redirect_to "#{@title.docs_path}"
    end
  end

  def publish_update
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_publishable?

    @item.publish

    docs_path = digitallibrary_doc_path(@item, title_id: @title.id)
    if @item.parent_id.blank?
      docs_path += "&cat=#{@item.id.to_s}"
    else
      docs_path += "&cat=#{@item.parent_id.to_s}"
    end
    redirect_to docs_path
  end

  def edit_file_memo
    @item = @title.docs.find(params[:parent_id])
    @file = @item.files.find(params[:id])
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
      params[:cat] = @parent.id
    else
      @parent = @title.folders.find_by(id: params[:cat])
    end
    params[:parent_id] = @parent.id if @parent
  end

  def index_docs
    @title.docs_and_folders.index_docs_with_params(@title, params)
      .index_order_with_params(@title, params)
      .search_with_params(@title, params)
  end

  def find_migrated_item
    if @item = @title.docs.find_by(serial_no: params[:id], migrated: 1)
      redirect_to url_for(params.merge(id: @item.id, title_id: @item.title_id, cat: @item.id))
    else
      http_error(404)
    end
  end

  def load_next_and_prev_item
    items = 
      case params[:state]
      when 'DRAFT', 'RECOGNIZE', 'PUBLISH', 'DATE'
        index_docs.select(:id, :parent_id, :title_id)
      else
        folders = @title.folders.roots.preload_public_children_for_prev_and_next_link
        collect_doc_items(folders)
      end

    current = items.index{|item| item.id == @item.id}.to_i
    @previous = items[current - 1] if current - 1 >= 0
    @next = items[current + 1]
  end

  def collect_doc_items(items)
    items.inject([]) do |arr, item|
      arr << item if item.doc_type_doc?
      arr += collect_doc_items(item.public_children_for_prev_and_next_link) if item.doc_type_folder?
      arr
    end
  end
end
