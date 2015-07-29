module Gwbbs::Controller::AdmsInclude

  def normal_index(pagenation_flag)
    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and "sql", gwbbs_select_status(params)
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
    c1.and :editor_id, Core.user.code

    c2 = Condition.new
    c1.and "sql", "state != 'public'"
    c2.and "sql", "state != 'preparation'"
    c2.and :title_id, params[:title_id]
    c2.and :editor_admin, 0
    c2.and :editordivision_id, Core.user_group.code

    c3 = Condition.new
    c3.and "sql", "state = 'public'"
    c3.and :title_id, params[:title_id]

    item = gwbbs_db_alias(Gwbbs::Doc)
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
    c1.and "sql", gwbbs_select_status(params)
    c1.and :title_id, params[:title_id]
    c1.and :editor_id, Core.user.code

    c2 = Condition.new
    c2.and "sql", gwbbs_select_status(params)
    c2.and :title_id, params[:title_id]
    c2.and :editor_admin, 0
    c2.and :editordivision_id, Core.user_group.code

    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.or c1
    item.or c2
    item.order  gwboard_sort_key(params)
    item.page   params[:page], params[:limit]
    @items = item.find(:all)
  end

  def all_index_admin
    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.and "sql", "state != 'preparation'"
    item.and :title_id, params[:title_id]
    item.search params
    item.order  'latest_updated_at DESC'
    item.page   params[:page], params[:limit]
    @items = item.find(:all)
  end

  def recognized_index_admin
    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and "sql", gwbbs_select_status(params)
    item.search params
    item.order  gwboard_sort_key(params)
    item.page   params[:page], params[:limit]
    @items = item.find(:all)
  end

  def recognize_index
    sql = Condition.new
    sql.and "sql", "gwbbs_recognizers.recognized_at Is Null"
    sql.and "sql", "gwbbs_recognizers.code = '#{Core.user.code}'"
    sql.and "sql", "gwbbs_docs.state = 'recognize'"

    join = "INNER JOIN gwbbs_recognizers ON gwbbs_docs.id = gwbbs_recognizers.parent_id AND gwbbs_docs.title_id = gwbbs_recognizers.title_id"

    item = gwbbs_db_alias(Gwbbs::Doc)
    item = item.new
    item.page   params[:page], params[:limit]
    @items = item.find(:all, :joins=>join, :conditions=>sql.where)
  end

end