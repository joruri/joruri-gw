# -*- encoding: utf-8 -*-
module Gwqa::Admin::DocsHelper
  include Gwqa::Model::DbnameAlias

  def is_qa_editable(is_admin, item)
    ret = false
    ret = true if is_admin
    ret = true if item.creater_id == Site.user.code
    ret = true if item.editor_id == Site.user.code
    return ret
  end

  def is_settlement(item)
    ret = true if item.creater_id == Site.user.code
    ret = true if item.editor_id == Site.user.code
    ret = false if item.content_state == "resolved"
    return ret
  end

  def anser_sort_link(item)
    if params[:qsort].blank?
      link_to(raw('回答の並び順<span>▲</span>'), "#{gwqa_doc_path(item,{:title_id=>item.title_id})}#{gwqa_params_set}&qsort=DESC",:title=>"現在昇順、クリックで降順に並び替え")
    else
      link_to(raw('回答の並び順<span>▲</span>'), "#{gwqa_doc_path(item,{:title_id=>item.title_id})}#{gwqa_params_set}",:title=>"現在降順、クリックで昇順に並び替え")
    end
  end

  def is_editable(is_admin, item)
    ret = false
    ret = true if is_admin
    ret = true if item.editor_id == Site.user.code if item.section_code == Site.user_group.code
    return ret
  end

  def qa_sort_link(title, sort_keys, path_index, field_name, other_query_string='')
    ret = sort_keys == "#{field_name}%20asc" ? '▲' : link_to_with_external_check('▲', path_index + "&sort_keys=" + "#{field_name}%20asc" + (other_query_string=='' ? '' : '&' + other_query_string ))
    ret += ' '
    ret += sort_keys == "#{field_name}%20desc" ? '▼' : link_to_with_external_check('▼', path_index + "&sort_keys=" + "#{field_name}%20desc" + (other_query_string=='' ? '' : '&' + other_query_string ))
    ret += "<br />"
    ret += title
    return ret
  end

  def answer_attach_files(item_id)
    item = gwqa_db_alias(Gwqa::File)
    item = item.new
    item.and :title_id, params[:title_id]
    item.and :parent_id, item_id
    item.order  'id'
    return item.find(:all)
  end

end
