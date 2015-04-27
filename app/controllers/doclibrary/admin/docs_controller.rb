class Doclibrary::Admin::DocsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  include Doclibrary::Admin::DocsHelper
  layout "admin/template/doclibrary"

  before_action :check_title_readable, only: [:index, :show]
  before_action :check_title_writable, only: [:new, :create, :edit, :update, :destroy]

  def pre_dispatch
    @title = Doclibrary::Control.find(params[:title_id])

    Page.title = @title.title
    return redirect_to("#{doclibrary_docs_path}?title_id=#{params[:title_id]}&limit=#{params[:limit]}&state=#{params[:state]}") if params[:reset]

    if params[:state].blank?
      params[:state] = 'CATEGORY' unless params[:cat].blank?
      params[:state] = 'GROUP' unless params[:gcd].blank?
      if params[:cat].blank?
        params[:state] = @title.default_folder.to_s if params[:state].blank?
      end if params[:gcd].blank?
    end

    _search_condition

    return http_error(404) if @parent.blank?
    initialize_value_set
  end

  def _search_condition
    @groups = Gwboard::Group.level3_all_hash
    @categories = @title.folders.where(state: 'public').select(:id, :name).index_by(&:id)

    case params[:state]
    when 'CATEGORY'
      if params[:cat].blank?
        @parent = @title.folders.root
        params[:cat] = @parent.id.to_s
      else
        @parent = @title.folders.find_by(id: params[:cat])
      end
    else
      if params[:cat].blank?
        @parent = @title.folders.root
      else
        @parent = @title.folders.find_by(id: params[:cat])
      end
    end
  end

  def index
    @items = @title.docs.index_select(@title)
      .index_docs_with_params(@title, params)
      .index_order_with_params(@title, params)
      .search_with_params(@title, params).distinct
      .paginate(page: params[:page], per_page: params[:limit])

    if params[:state].in?(%w(CATEGORY DRAFT))
      @folders = @title.folders.index_folders_with_params(@title, params)
        .search_with_params(@title, params)
        .paginate(page: params[:page], per_page: params[:limit])
    end

    if params[:kwd].present?
      @files = @title.files.search_with_params(@title, params)
        .merge(@title.docs.index_docs_with_params(@title, params)).joins(:doc)
        .index_order_with_params(@title, params).distinct
        .paginate(page: params[:page], per_page: params[:limit])
    end
  end

  def show
    @item = @title.docs.find_by(id: params[:id])
    return find_migrated_item unless @item
    return error_auth if !@title.is_readable? && !@item.is_recognizable? && !@item.is_publishable?
    return error_auth if @item.state == 'draft' && !@item.is_editable?
    return error_auth unless @item.folder.is_readable?

    Page.title = @item.title

    if @title.form_name == 'form002'
      @parent = @title.folders.find_by(id: @item.category1_id)
    end
  end

  def new
    str_section_code = Core.user_group.code
    str_section_code = params[:gcd].to_s unless params[:gcd].to_s == '1' unless params[:gcd].blank?
    @item = Doclibrary::Doc.create({
      :state => 'preparation',
      :title_id => @title.id ,
      :latest_updated_at => Time.now,
      :importance=> 1,
      :one_line_note => 0,
      :section_code => str_section_code ,
      :category4_id => 0,
      :category1_id => params[:cat],
      :wiki => 0
    })

    @item.state = 'draft'
  end

  def edit
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_editable?
    return error_auth unless @item.folder.is_readable?
  end

  def update
    @item = @title.docs.find(params[:id])

    @item.attributes = params[:item]
    @item.latest_updated_at = Time.now unless @item.skip_updating_updated_at == '1'
    @item.category_use = 1
    @item.form_name = @title.form_name
    @item.section_name = @item.section.code + @item.section.name if @item.section

    _update @item, success_redirect_uri: doclibrary_docs_path(title_id: @title.id) + doclib_uri_params
  end

  def destroy
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_editable?

    _destroy @item, success_redirect_uri: doclibrary_docs_path(title_id: @title.id) + doclib_uri_params
  end

  def file_exports
    show # 詳細を使用して、同様の権限、データの取得を行う

    if @title.form_name == 'form002'
      zipdata = @item.compress_category_files
    else
      zipdata = @item.compress_files
    end

    if zipdata.present?
      file_name = "#{@title.title}_#{@item.title}"[0,100]
      file_name = file_name + "_#{Time.now.strftime("%Y%m%d%H%M%S")}.zip"
      send_data zipdata, filename: file_name
    else
      flash[:notice] = '出力対象の添付ファイルがありません。'
      redirect_to @item.show_path
    end
  end

  def edit_file_memo
    @item = @title.docs.find(params[:parent_id])
    @file = @item.files.find(params[:id])
  end

  def recognize_update
    @item = @title.docs.find(params[:id])

    @item.recognize(Core.user)

    if @title.is_writable?
      redirect_to doclibrary_docs_path(title_id: @title.id, state: 'RECOGNIZE')
    else
      redirect_to doclibrary_docs_path(title_id: @title.id)
    end
  end

  def publish_update
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_publishable?

    @item.publish

    redirect_to doclibrary_docs_path(title_id: @title.id)
  end

  private

  def check_title_readable
    return error_auth unless @title.is_readable?
  end

  def check_title_writable
    return error_auth unless @title.is_writable?
  end

  def find_migrated_item
    if @item = @title.docs.find_by(serial_no: params[:id], migrated: 1)
      redirect_to url_for(params.merge(id: @item.id, title_id: @item.title_id, cat: @item.category1_id))
    else
      http_error(404)
    end
  end
end
