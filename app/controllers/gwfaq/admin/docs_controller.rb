class Gwfaq::Admin::DocsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/gwfaq"

  before_action :check_title_readable, only: [:index, :show]
  before_action :check_title_writable, only: [:new, :create, :edit, :update, :destroy]

  def pre_dispatch
    @title = Gwfaq::Control.find(params[:title_id])

    Page.title = @title.title

    params[:state] = "CATEGORY" if params[:state].blank? && @title.category == 1

    return redirect_to(gwfaq_docs_path({:title_id=>@title.id}) + "&limit=#{params[:limit]}&state=#{params[:state]}") if params[:reset]

    _search_condition

    initialize_value_set_new_css
  end

  def _search_condition
    @categories1 = @title.categories.select(:id, :name).where(level_no: 1).order(:sort_no, :id)
    @d_categories = @categories1.index_by(&:id)
  end

  def index
    @items = @title.docs.index_select.index_docs_with_params(@title, params)
      .index_order_with_params(@title, params)
      .search_with_params(@title, params)
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = @title.docs.find_by(id: params[:id])
    return find_migrated_item unless @item
    return error_auth if !@title.is_readable? && !@item.is_recognizable? && !@item.is_publishable?

    Page.title = @item.title unless @item.title.blank?
  end

  def new
    @item = Gwfaq::Doc.create(
      :state => 'preparation',
      :title_id => @title.id,
      :latest_updated_at => Time.now,
      :importance=> 1,
      :one_line_note => 0,
      :section_code => Core.user_group.code,
      :category4_id => 0,
      :title => '',
      :body => '',
      :wiki => 0
    )

    @item.state = 'draft'
  end

  def edit
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_editable?

    @item.category4_id = 0 if @item.category4_id.blank?
  end

  def update
    @item = @title.docs.find(params[:id])

    @item.attributes = doc_params
    @item.latest_updated_at = Time.now
    @item.category_use = @title.category
    @item.section_name = @item.section.code + @item.section.name if @item.section

    case @item.state
    when 'public'
      next_location = "#{gwfaq_docs_path({:title_id=>@title.id})}"
    when 'draft'
      next_location = "#{gwfaq_docs_path({:title_id=>@title.id})}&state=DRAFT"
    when 'recognize'
      next_location = "#{gwfaq_docs_path({:title_id=>@title.id})}&state=RECOGNIZE"
    else
      next_location = "#{gwfaq_docs_path({:title_id=>@title.id})}#{gwbbs_params_set}"
    end

    _update @item, success_redirect_uri: next_location
  end

  def destroy
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_editable?

    _destroy @item, :success_redirect_uri => gwfaq_docs_path({:title_id=>@title.id})
  end

  def recognize_update
    @item = @title.docs.find(params[:id])

    @item.recognize(Core.user)

    if @title.is_writable?
      redirect_to gwfaq_docs_path(title_id: @title.id, state: 'RECOGNIZE')
    else
      redirect_to gwfaq_docs_path(title_id: @title.id)
    end
  end

  def publish_update
    @item = @title.docs.find(params[:id])
    return error_auth unless @item.is_publishable?

    @item.publish

    redirect_to gwfaq_docs_path(title_id: @title.id)
  end

  private

  def doc_params
    params.require(:item).permit(:body, :category1_id, :state,
      :title, :wiki_body, :wiki, :section_code, :skip_updating_updated_at,
      :selected_recognizer_uids => [])
  end

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
