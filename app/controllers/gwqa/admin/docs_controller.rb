class Gwqa::Admin::DocsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/gwqa"

  before_action :check_title_readable, only: [:index, :show]
  before_action :check_title_writable, only: [:new, :create, :edit, :update, :destroy, :settlement]

  def pre_dispatch
    @title = Gwqa::Control.find(params[:title_id])

    Page.title = @title.title

    str_param = ''
    str_param += "&state=#{params[:state]}" unless params[:state].blank?
    return redirect_to(gwqa_docs_path({:title_id=>@title.id}) + "#{str_param}") if params[:reset]

    _search_condition

    initialize_value_set_new_css
  end

  def _search_condition
    @categories1 = @title.categories.select(:id, :name).where(level_no: 1).order(:sort_no, :id)
    @d_categories = @categories1.index_by(&:id)
  end

  def index
    @items = @title.docs.index_select.search_with_params(@title, params)
      .index_docs_with_params(@title, params)
      .index_order_with_params(@title, params)
      .question_docs
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = @title.docs.find_by(id: params[:id])
    return find_migrated_item unless @item
    return http_error(404) if @item.doc_type != 0
    return error_auth if !@item.is_editable? && @item.state == "draft"

    if params[:qsort].to_s == 'DESC'
      @answers = @item.public_answers.reorder(created_at: :desc)
    else
      @answers = @item.public_answers.reorder(created_at: :asc)
    end
  end

  def new
    return http_error(404) if params[:p_id].blank?

    doc_type = 0
    parent_id = 0
    unless params[:p_id] == 'Q'
      doc_type = 1
      parent_id = params[:p_id]
    end

    if doc_type == 1
      @parent = @title.docs.find(parent_id)
      return http_error(404) if @parent.doc_type != 0
    end

    @item = Gwqa::Doc.create(
      :doc_type =>  doc_type ,
      :state => 'preparation',
      :title_id   => @title.id ,
      :parent_id => parent_id ,
      :published_at  => Time.now ,
      :content_state => 'unresolved',
      :title => '',
      :body => '',
      :answer_count => 0,
      :section_code => Core.user_group.code,
      :latest_updated_at => Time.now,
      :wiki => 0
    )

    @item.state = 'draft'
  end

  def edit
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_editable?
  end

  def update
    return http_error(404) if params[:p_id].blank?

    doc_type = 0
    parent_id = params[:id]
    if params[:p_id] != 'Q'
      doc_type = 1
      parent_id = params[:p_id]
    else
      parent_id = params[:id]
    end

    @item = @title.docs.find(params[:id])

    @item.attributes = params[:item]
    @item.latest_updated_at = Core.now
    @item.doc_type = doc_type
    @item.parent_id = parent_id
    @item.category_use = @title.category
    @item.section_name = @item.section.code + @item.section.name if @item.section

    _update @item, success_redirect_uri: gwqa_docs_path(title_id: @title.id)
  end

  def destroy
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_editable?

    str_param = ''
    str_param = "&state=#{params[:state]}" unless params[:state].blank?
    str_param = "&cat1=#{params[:cat1]}" unless params[:cat1].blank?
    str_param = "&page=#{params[:page]}" unless params[:page].blank?
    str_param = "&limit=#{params[:limit]}" unless params[:limit].blank?
    str_param = "&kwd=#{params[:kwd]}" unless params[:kwd].blank?
    _destroy @item, success_redirect_uri: "#{gwqa_docs_path({:title_id=>@title.id})}#{str_param}"
  end

  def settlement
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_editable?

    @item.content_state = 'resolved'
    @item.save

    str_param = ''
    str_param = "&state=#{params[:state]}" unless params[:state].blank?
    str_param = "&cat1=#{params[:cat1]}" unless params[:cat1].blank?
    str_param = "&page=#{params[:page]}" unless params[:page].blank?
    str_param = "&limit=#{params[:limit]}" unless params[:limit].blank?
    str_param = "&kwd=#{params[:kwd]}" unless params[:kwd].blank?

    return redirect_to "#{gwqa_docs_path({:title_id=>@title.id})}#{str_param}"
  end

  def latest_answer
    item = Gwqa::Doc
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :doc_type, 1
    item.order :latest_updated_at
    @items = item.find(:all)
    for up_item in @items
      up_item.answer_date_update
    end
    redirect_to "/gwqa"
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
      redirect_to url_for(params.merge(id: @item.id, title_id: @item.title_id))
    else
      http_error(404)
    end
  end
end
