module Gwqa::Controller::AdmsInclude
  include Gwboard::Controller::SortKey

  def normal_index(pagenation_flag)
    item = gwqa_db_alias(Gwqa::Doc)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and "sql", gwboard_select_status(params)
    item.search params
    item.order  gwboard_sort_key(params)
    #
    item.page   params[:page], params[:limit] if pagenation_flag
    @items = item.find(:all)
  end

end