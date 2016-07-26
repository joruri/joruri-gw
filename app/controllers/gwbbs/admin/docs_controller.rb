class Gwbbs::Admin::DocsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/gwbbs"

  before_action :check_title_readable, only: [:index, :show]
  before_action :check_title_writable, only: [:new, :create, :edit, :update, :destroy]

  def pre_dispatch
    @title = Gwbbs::Control.find(params[:title_id])

    return redirect_to("/gwbbs/docs?title_id=#{params[:title_id]}&state=#{params[:state]}") if params[:reset]

    _category_condition

    initialize_value_set_new_css

    params[:state] = @title.default_mode if params[:state].blank?
    Page.title = @title.title
    @css = ["/_common/themes/gw/css/gwbbs_standard.css", "/_common/themes/gw/css/doc_2column.css"]
  end

  def _category_condition
    @categories1 = @title.categories.select(:id, :name).where(level_no: 1).order(:sort_no, :id)
    @d_categories = @categories1.index_by(&:id)
  end

  def index
    @items = index_docs.index_select(@title).paginate(page: params[:page], per_page: params[:limit])

    if params[:kwd].present?
      @files = @title.files.search_with_text(:filename, params[:kwd])
        .merge(@title.docs.index_docs_with_params(@title, params)).joins(:doc).order(:filename)
        .paginate(page: params[:page], per_page: params[:limit])
    end
    Page.title = @title.title
  end

  def show
    @item = @title.docs.find_by(id: params[:id])
    return find_migrated_item unless @item
    return error_auth if !@title.is_readable? && !@item.is_recognizable? && !@item.is_publishable?
    @item.set_read_flag
    # 前後記事
    items = index_docs.select(:id, :title_id)
    current = items.index{|item| item.id == @item.id}.to_i
    @previous = items[current - 1] if current - 1 >= 0
    @next = items[current + 1]

    # 福利厚生ポータルへのリンク情報を取得
    link_hss_portal

    ptitle = ''
    ptitle = @title.notes_field09 unless @title.notes_field09.blank? if @title.form_name == 'form003'
    ptitle = @item.title unless @title.form_name == 'form003'
    Page.title = ptitle unless ptitle.blank?
  end

  def new
    @item = Gwbbs::Doc.create(
      :state => 'preparation',
      :title_id => @title.id,
      :latest_updated_at => Time.now,
      :importance=> 1,
      :one_line_note => 0,
      :title => '',
      :body => '',
      :section_code => Core.user_group.code,
      :category4_id => 0,
      :able_date => Time.now.strftime("%Y-%m-%d"),
      :expiry_date => (@title.default_published || 3).months.since.strftime("%Y-%m-%d"),
      :wiki => 0
    )

    @item.state = 'draft'
    @item.inpfld_024 = '家族' if @title.form_name == "form003"
  end

  def edit
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_editable?

    @item.category4_id = 0 if @item.category4_id.blank?

    Page.title = @title.title
  end

  def update
    @item = @title.docs.find(params[:id])

    @item.attributes = params[:item]
    @item.latest_updated_at = Time.now unless @item.skip_updating_updated_at == '1'

    unless @item.expiry_date.blank?
      @item.expiry_date = "#{@item.expiry_date.strftime("%Y-%m-%d")} 23:59:59"  if @item.expiry_date.strftime('%H:%M') == '00:00'
    end
    @item.category_use = @title.category
    @item.form_name = @title.form_name
    @item.section_name = @item.section.code + @item.section.name if @item.section

    case @item.state
    when 'public'
      next_location = "#{@title.docs_path}"
    when 'draft'
      next_location = "#{@title.docs_path}&state=DRAFT"
    when 'recognize'
      next_location = "#{@title.docs_path}&state=RECOGNIZE"
    else
      next_location = "#{@title.docs_path}#{gwbbs_params_set}"
    end

    _update @item, success_redirect_uri: next_location
  end

  def destroy
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_editable?

    _destroy @item, success_redirect_uri: "#{@title.docs_path}#{gwbbs_params_set}"
  end

  def destroy_void_documents
    return error_auth unless @title.is_admin?

    @title.docs.where(state: 'preparation').created_before(Date.yesterday).destroy_all
    @title.docs.where(state: 'public').where("expiry_date < ?", Time.now).destroy_all

    redirect_to "#{@title.docs_path}#{gwbbs_params_set}"
  end

  def file_exports
    show # 詳細を使用して、同様の権限、データの取得を行う

    zipdata = @item.compress_files

    if zipdata.present?
      file_name = "#{@title.title}_#{@item.title}"[0,100]
      file_name = file_name + "_#{Time.now.strftime("%Y%m%d%H%M%S")}.zip"
      send_data zipdata, filename: file_name
    else
      flash[:notice] = '出力対象の添付ファイルがありません。'
      redirect_to @item.show_path + gwbbs_params_set
    end
  end

  def clone
    @item = @title.docs.find(params[:id])

    if @new_item = @item.duplicate
      redirect_to @new_item.edit_path + gwbbs_params_set
    else
      flash[:notice] = '複製に失敗しました'
      redirect_to @item.show_path + gwbbs_params_set
    end
  end

  def edit_file_memo
    return error_auth unless @title.is_readable?

    @item = @title.docs.find(params[:parent_id])
    @file = @item.files.find(params[:id])
  end

  def recognize_update
    @item = @title.docs.find(params[:id])

    @item.recognize(Core.user)

    if @title.is_writable?
      redirect_to gwbbs_docs_path(title_id: @title.id, state: 'RECOGNIZE')
    else
      redirect_to gwbbs_docs_path(title_id: @title.id)
    end
  end

  def publish_update
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_publishable?

    @item.publish

    redirect_to @title.docs_path
  end

  private

  def check_title_readable
    return error_auth unless @title.is_readable?
  end

  def check_title_writable
    return error_auth unless @title.is_writable?
  end

  def link_hss_portal
    @link_to_hcs_url = if @item.hcs_link_target?
        "/_admin/gw/link_sso/redirect_to_joruri?to=hcs&path=/hcs/portal"
      else
        nil
      end
  end

  def index_docs
    @title.docs.index_docs_with_params(@title, params)
      .index_order_with_params(@title, params)
      .search_with_params(@title, params)
  end

  def find_migrated_item
    if @item = @title.docs.find_by(serial_no: params[:id], migrated: 1)
      redirect_to url_for(params.merge(id: @item.id, title_id: @item.title_id))
    else
      http_error(404)
    end
  end
end
