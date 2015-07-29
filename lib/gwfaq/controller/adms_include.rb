module Gwfaq::Controller::AdmsInclude

  def normal_index(pagenation_flag)
    item = gwfaq_db_alias(Gwfaq::Doc)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and "sql", gwboard_select_status(params)
    item.search params
    item.order  gwboard_sort_key(params)

    item.page   params[:page], params[:limit] if pagenation_flag
    @items = item.find(:all)
  end

  def all_index
    c1 = Condition.new
    c1.and "sql", "state != 'public'"
    c1.and "sql", "state != 'preparation'"
    c1.and :title_id, params[:title_id]
    c1.and :editor_id, Site.user.code


    c2 = Condition.new
    c1.and "sql", "state != 'public'"
    c2.and "sql", "state != 'preparation'"
    c2.and :title_id, params[:title_id]
    c2.and :editor_admin, 0
    c2.and :editordivision_id, Site.user_group.code


    c3 = Condition.new
    c3.and "sql", "state = 'public'"
    c3.and :title_id, params[:title_id]

    item = gwfaq_db_alias(Gwfaq::Doc)
    item = item.new
    item.or c1
    item.or c2
    item.or c3
    item.order  'latest_updated_at DESC'
    item.page   params[:page], params[:limit]
    @items = item.find(:all)
  end

  def recognized_index

    c1 = Condition.new
    c1.and "sql", gwboard_select_status(params)
    c1.and :title_id, params[:title_id]
    c1.and :editor_id, Site.user.code


    c2 = Condition.new
    c2.and "sql", gwboard_select_status(params)
    c2.and :title_id, params[:title_id]
    c2.and :editor_admin, 0
    c2.and :editordivision_id, Site.user_group.code

    item = gwfaq_db_alias(Gwfaq::Doc)
    item = item.new
    item.or c1
    item.or c2
    item.order  gwboard_sort_key(params)
    item.page   params[:page], params[:limit]
    @items = item.find(:all)
  end

  def all_index_admin
    item = gwfaq_db_alias(Gwfaq::Doc)
    item = item.new
    item.and "sql", "state != 'preparation'"
    item.and :title_id, params[:title_id]
    item.search params
    item.order  'latest_updated_at DESC'
    item.page   params[:page], params[:limit]
    @items = item.find(:all)
  end

  def recognized_index_admin
    item = gwfaq_db_alias(Gwfaq::Doc)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and "sql", gwboard_select_status(params)
    item.search params
    item.order  gwboard_sort_key(params)
    item.page   params[:page], params[:limit]
    @items = item.find(:all)
  end

  def recognize_index
    sql = Condition.new
    sql.and "sql", "gwfaq_recognizers.recognized_at Is Null"
    sql.and "sql", "gwfaq_recognizers.code = '#{Site.user.code}'"
    sql.and "sql", "gwfaq_docs.state = 'recognize'"

    join = "INNER JOIN gwfaq_recognizers ON gwfaq_docs.id = gwfaq_recognizers.parent_id AND gwfaq_docs.title_id = gwfaq_recognizers.title_id"

    item = gwfaq_db_alias(Gwfaq::Doc)
    item = item.new
    item.page   params[:page], params[:limit]
    @items = item.find(:all, :joins=>join, :conditions=>sql.where)
  end

end