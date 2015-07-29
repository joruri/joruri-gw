class Gwqa::Admin::DocsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwqa::Model::DbnameAlias
  include Gwboard::Controller::Authorize

  layout "admin/template/gwqa"

  def initialize_scaffold
    @title = Gwqa::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title
    Page.title = @title.title

    str_param = ''
    str_param += "&state=#{params[:state]}" unless params[:state].blank?
    return redirect_to(gwqa_docs_path({:title_id=>@title.id}) + "#{str_param}") if params[:reset]

    begin
      _search_condition
    rescue
      return error_gwbbs_no_database
    end

    initialize_value_set_new_css
  end

  def _search_condition
    item = gwqa_db_alias(Gwqa::Category)
    item = item.new
    item.and :level_no, 1
    item.and :title_id, params[:title_id]
    @categories1 = item.find(:all, :order =>'sort_no, id')
    @d_categories = item.find(:all,:select=>'id, name', :order =>'sort_no, id').index_by(&:id)
    Gwqa::Category.remove_connection
  end

  def index
    get_role_index
    return authentication_error(403) unless @is_readable

    if params[:kwd].blank?
      index_normal
    else
      index_search
    end

    Gwqa::Doc.remove_connection
  end

  def index_normal
    item = gwqa_db_alias(Gwqa::Doc)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :doc_type, 0
    item.and "sql", gwqa_select_status(params)
    item.search params
    item.order  gwboard_sort_key(params)
    item.page   params[:page], params[:limit]
    @items = item.find(:all)
  end

  def index_search

    item = gwqa_db_alias(Gwqa::Doc)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and "sql", gwqa_select_status(params)
    item.search params
    records = item.find(:all,:select=>'parent_id', :group=>'parent_id')
    unless records.blank?

      strsql = ''
      for record in records
        strsql += ' OR ' unless strsql.blank?
        strsql += "id=#{record.parent_id}"
      end
      strsql = "(#{strsql})" unless strsql.blank?
    else

      strsql = '(id=0)'
    end

    item = gwqa_db_alias(Gwqa::Doc)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :doc_type, 0
    item.and "sql", strsql
    item.and "sql", gwqa_select_status(params)
    item.order  gwboard_sort_key(params)
    item.page   params[:page], params[:limit]
    @items = item.find(:all)
  end

  def show
    get_role_index
    return authentication_error(403) unless @is_readable

    item = gwqa_db_alias(Gwqa::Doc)
    item = item.new
    item.and :id, params[:id]
    item.and :doc_type, 0
    item.and :title_id, params[:title_id]
    @item = item.find(:first)
    return http_error(404) unless @item

    get_role_new
    @is_editable = Gwqa::Model::DbnameAlias.get_editable_flag(@item, @is_admin, @is_writable)

    return http_error(404) if @item.state == "draft" unless @is_editable

    item = gwqa_db_alias(Gwqa::File)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, @item.id
    item.order  'id'
    @files = item.find(:all)

    item = gwqa_db_alias(Gwqa::Doc)
    item = item.new
    item.and :parent_id, params[:id]
    item.and :doc_type, 1
    item.and :title_id, params[:title_id]
    item.and :state, 'public'
    item.order  'created_at' unless params[:qsort].to_s == 'DESC'
    item.order  'created_at DESC' if params[:qsort].to_s == 'DESC'
    @answers = item.find(:all)

    Gwqa::Doc.remove_connection
  end

  def new
    return http_error(404) if params[:p_id].blank?

    get_role_new
    return authentication_error(403) unless @is_writable

    doc_type = 0
    parent_id = 0
    unless params[:p_id] == 'Q'
      doc_type = 1
      parent_id = params[:p_id]
    end
    return http_error(404) unless is_integer(parent_id)

    if doc_type == 1
      item = gwqa_db_alias(Gwqa::Doc)
      item = item.new
      item.and :id, parent_id
      item.and :doc_type, 0
      item.and :title_id, params[:title_id]
      @parent = item.find(:first)
      return http_error(404) unless @parent
    end

    item = gwqa_db_alias(Gwqa::Doc)
    @item = item.create({
      :doc_type =>  doc_type ,
      :state => 'preparation',
      :title_id   => @title.id ,
      :parent_id => parent_id ,
      :published_at  => Time.now ,
      :content_state => 'unresolved',
      :title => '',
      :body => '',
      :answer_count => 0,
      :section_code => Site.user_group.code,
      :latest_updated_at => Time.now
    })

    @item.state = 'draft'
    reference_docs if doc_type == 1
  end

  def edit
    get_role_new
    return authentication_error(403) unless @is_writable

    item = gwqa_db_alias(Gwqa::Doc)
    item = item.new
    item.and :id, params[:id]
    item.and :title_id, params[:title_id]
    @item = item.find(:first)
    Gwqa::Doc.remove_connection
    return http_error(404) unless @item

    @is_editable = Gwqa::Model::DbnameAlias.get_editable_flag(@item, @is_admin, @is_writable)
    return authentication_error(403) unless @is_editable

    reference_docs if @item.doc_type == 1
  end

  def update
    return http_error(404) if params[:p_id].blank?

    get_role_new
    return authentication_error(403) unless @is_writable

    doc_type = 0
    parent_id = params[:id]
    if params[:p_id] != 'Q'
      doc_type = 1
      parent_id = params[:p_id]
    else
      parent_id = params[:id]
    end
    return http_error(404) unless is_integer(parent_id)

    item = gwqa_db_alias(Gwqa::Doc)
    @item = item.find(params[:id])

    @item.attributes = params[:item]
    @item.latest_updated_at = Core.now
    @item.doc_type = doc_type
    @item.parent_id = parent_id
    @item.category_use = @title.category

    update_creater_editor

    group = Gwboard::Group.new
    group.and :state , 'enabled'
    group.and :code ,@item.section_code
    group = group.find(:first)
    @item.section_name = group.code + group.name if group
    @item._note_section = group.name if group

    @item._bbs_title_name = @title.title
    @item._notification = @title.notification

    _update_plus_location @item, gwqa_docs_path({:title_id=>@title.id})
  end

  def destroy
    get_role_new

    item = gwqa_db_alias(Gwqa::Doc)
    @item = item.new.find(params[:id])

    @is_editable = Gwqa::Model::DbnameAlias.get_editable_flag(@item, @is_admin, @is_writable)
    return authentication_error(403) unless @is_editable

    destroy_atacched_files
    destroy_files

    @item._notification = @title.notification

    str_param = ''
    str_param = "&state=#{params[:state]}" unless params[:state].blank?
    str_param = "&cat1=#{params[:cat1]}" unless params[:cat1].blank?
    str_param = "&page=#{params[:page]}" unless params[:page].blank?
    str_param = "&limit=#{params[:limit]}" unless params[:limit].blank?
    str_param = "&kwd=#{params[:kwd]}" unless params[:kwd].blank?
    local = "#{gwqa_docs_path({:title_id=>@title.id})}#{str_param}"
    _destroy_plus_location(@item, local)
  end

  def sql_where
    sql = Condition.new
    sql.and "parent_id", @item.id
    sql.and "title_id", @item.title_id
    return sql.where
  end

  def destroy_atacched_files
    item = gwqa_db_alias(Gwqa::File)
    item.destroy_all(sql_where)
    Gwqa::File.remove_connection
  end

  def destroy_files
    item = gwqa_db_alias(Gwqa::DbFile)
    item.destroy_all(sql_where)
    Gwqa::DbFile.remove_connection
  end

  def settlement
    get_role_new
    return authentication_error(403) unless @is_writable

    item = gwqa_db_alias(Gwqa::Doc)
    item = item.new
    item.and :id, params[:id]
    item.and :title_id, @title.id
    @item = item.find(:first)
    Gwqa::Doc.remove_connection
    return http_error(404) unless @item
    @is_editable = Gwqa::Model::DbnameAlias.get_editable_flag(@item, @is_admin, @is_writable)
    return authentication_error(403) unless @is_editable
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
    item = gwqa_db_alias(Gwqa::Doc)
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

  def is_integer(no)
    if no == nil
      return false
    else
      begin
        Integer(no)
      rescue
        return false
      end
    end
  end

  def reference_docs
    item = gwqa_db_alias(Gwqa::Doc)
    item = item.new
    item.and :id, @item.parent_id
    item.and :doc_type, 0
    item.and :title_id, @title.id
    @reference_item = item.find(:first)
    return http_error(404) unless @reference_item

    item = gwqa_db_alias(Gwqa::File)
    item = item.new
    item.and :title_id, @title.id
    item.and :parent_id, @reference_item.id
    item.order  'id'
    @files = item.find(:all)

    item = gwqa_db_alias(Gwqa::Doc)
    item = item.new
    item.and :parent_id, @item.parent_id
    item.and :doc_type, 1
    item.and :title_id, @title.id
    item.and :state, 'public'
    item.order  'created_at' unless params[:qsort].to_s == 'DESC'
    item.order  'created_at DESC' if params[:qsort].to_s == 'DESC'
    @reference_answers = item.find(:all)

    Gwqa::Doc.remove_connection
  end

end
