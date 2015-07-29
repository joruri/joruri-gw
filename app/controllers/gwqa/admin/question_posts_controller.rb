class Gwqa::Admin::QuestionPostsController < Gw::Controller::Admin::Base
  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::SortKey
  include Gwqa::Model::DbnameAlias

  layout "admin/template/portal_1column"


  def initialize_scaffold
    @title = Gwqa::Control.find_by_id(params[:title_id])
    return error_gwbbs_no_title unless @title
    return redirect_to(Site.current_node.public_uri.chop + '?title_id=' + params[:title_id]+ '&limit=' + params[:limit]) if params[:reset]
    params[:limit] = @title.default_limit.to_s if params[:limit].blank?
    Page.title = @title.title
    if @title.css.to_s != ""
      @css = [@title.css.to_s]
    else
      @css = ['/_common/themes/gw/css/gwboard/gwbbs_standard.css']
    end

    @img_path = "/_common/modules/gwqa/"

  end

  def index
    redirect_to '/gwqa/docs?title_id=' + params[:title_id]
  end

  def show
    item = gwqa_db_alias(Gwqa::Doc)
    item = item.new
    item.and :id, params[:id]
    item.and :doc_type, 0
    @item = item.find(:first)
    return http_error(404) unless @item
  end

  def is_user_compare(item)
    user_compare = false
    unless item.creator.nil?
      user_compare = true if Site.user.code == item.creater_id
    end
    return user_compare
  end

  def new
    @title = @qa_control_table.find_by_id(params[:title_id])
    return error_gwbbs_no_title unless is_authorized(@title)

    @item = @qa_doc_table.new({
      :state => 'public' ,
      :content_state => 'unresolved' ,
      :title_id   => @title.id ,
      :doc_type => 0 ,
      :published_at  => Core.now ,
      :content_id => Site.current_node.content_id
    })
  end

  def create
    @title = @qa_control_table.find_by_id(params[:title_id])
    return error_gwbbs_no_title unless is_authorized(@title)

    @item = @qa_doc_table.new(params[:item])
    @item.doc_type  = 0
    @item.title_id  = @title.id
    @item.latest_updated_at = Core.now
    @item.content_id = Site.current_node.content_id
    @item.keywords = @item.head + ' ' + @item.body

    @item.createdate = Core.now
    @item.creater_id = Site.user.code unless Site.user.code.blank?
    @item.creater = Site.user.name unless Site.user.name.blank?
    @item.createrdivision = Site.user_group.name unless Site.user_group.name.blank?

    _create_after_set_location @item
  end

  def edit
    @title = @qa_control_table.find_by_id(params[:title_id])
    return error_gwbbs_no_title unless @title

    item = @qa_doc_table.new
    @item = item.find(params[:id])
    return error_gwbbs_no_title unless @item

    p is_user_compare(@item)
    unless is_user_compare(@item)
        redirect_to @item.gwqa_doc_queston_show_path
    end
  end

  def update
    @title = @qa_control_table.find_by_id(params[:title_id])
    return error_gwbbs_no_title unless is_authorized(@title)

    @item = @qa_doc_table.new.find(params[:id])
    @item.attributes = params[:item]
    @item.keywords = @item.head + ' ' + @item.body

    @item.editdate = Core.now
    @item.editor_id = Site.user.code unless Site.user.code.blank?
    @item.editor = Site.user.name unless Site.user.name.blank?
    @item.editordivision = Site.user_group.name unless Site.user_group.name.blank?

    if @item.state == 'recognized'
      location = @item.gwqa_preview_path
    else
      location = @item.gwqa_preview_index_path
    end

    _update_plus_location @item, location
  end


  def destroy
    @item = @qa_doc_table.new.find(params[:id])
    _destroy_plus_location(@item, @item.qa_doc_path + "?title_id=#{params[:title_id]}") if is_user_compare(@item)
  end

end
