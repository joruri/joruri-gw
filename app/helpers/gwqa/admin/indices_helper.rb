# -*- encoding: utf-8 -*-
module Gwqa::Admin::IndicesHelper

  def gwqa_params_set
    str = ''
    str += "&state=#{params[:state]}" unless params[:state].blank?
    str += "&cat1=#{params[:cat1]}" unless params[:cat1].blank?
    str += "&grp=#{params[:grp]}" unless params[:grp].blank?
    str += "&yyyy=#{params[:yyyy]}" unless params[:yyyy].blank?
    str += "&mm=#{params[:mm]}" unless params[:mm].blank?
    str += "&page=#{params[:page]}" unless params[:page].blank?
    str += "&limit=#{params[:limit]}" unless params[:limit].blank?
    str += "&kwd=#{URI.encode(params[:kwd])}" unless params[:kwd].blank?
    return str
  end

  def gwqa_form_indices
    ret = ""
    case params[:state]
    when "TODAY"
      ret = gwqa_form_indices_date
    when "DATE"
      ret = gwqa_form_indices_date
    when "GROUP"
      ret = gwqa_form_indices_group
    when "CATEGORY"
      ret = gwqa_form_indices_category
    else
      ret = gwqa_form_indices_date
    end
    return ret.html_safe
  end

  def gwqa_start_line
    l_limit = is_integer(params[:limit])
    l_limit = 30 unless l_limit
    l_page = is_integer(params[:page])
    unless l_page
      l_page = 0
    else
      l_page = l_page - 1
      l_page = 0 if l_page < 0
    end
    return l_limit * l_page
  end

  def ret_answers(attach)
    str = ''
    unless attach.blank?
      str =  "<span>#{attach.to_s}</span>" unless attach.to_s == '0'
    end
    return str
  end

  def ret_resolved(content_state)
    if content_state != "resolved"
      return ''
    else
      return '<span>解決済</span>'
    end
  end

  def gwqa_form_indices_date
    mode = ''
    mode = 'date' unless @title.categoey_view
    mode = 'date' if @title.category == 0

    brk_key = nil
    ret = '<table class="index">'
    i = 0
    ret += '<tr class="headIndex">'
    ret += '<th class="docTitle">記事タイトル</th>'
    ret += '<th class="item">' + "回答数</th>"
    ret += '<th class="item">' + "状況</th>"
    ret += '<th class="category">' + "#{@title.category1_name unless @title.category1_name.blank?}</th>" if mode.blank?
    ret += '<th class="group">' + "回答最終更新日時</th>"
    ret += "</tr>"
    for item in @items
      unless brk_key == item.latest_updated_at.strftime('%Y-%m-%d').to_s
        i = 0
        ret += '<tr class="subIndex">'
        ret += '<th class="docTitle">■ ' + item.latest_updated_at.strftime('%Y-%m-%d').to_s  + "</th>"
        ret += '<th class="item">' + "</th>"
        ret += '<th class="item">' + "</th>"
        ret += '<th class="category"></th>' if mode.blank?
        ret += '<th class="group"></th>'
        ret += "</tr>"
      end

      i += 1
      tr = (i%2 != 0) ? '<tr class="article">' : '<tr class="article cycle">'
      ret += tr.to_s
      ret += '<td class="docTitle">' + link_to(hbr(item.title), gwqa_doc_path(item,{:title_id=>item.title_id}) + gwqa_params_set) + "</td>"
      ret += '<td class="qaAnswer " >' + ret_answers(item.answer_count) + "</td>"
      ret += '<td class="qaSettled ">' + ret_resolved(item.content_state) + "</td>"
      ret += '<td class="category">' + gwbd_category_name(@d_categories,item.category1_id) + "</td>" if mode.blank?
      s_answer = ''
      s_answer = item.latest_answer.strftime('%Y-%m-%d %H:%M').to_s unless item.latest_answer.blank?
      ret += '<td class="group">' + s_answer + "</td>"
      ret += "</tr>"
      brk_key = item.latest_updated_at.strftime('%Y-%m-%d').to_s
    end
    ret += "</table>"
    return ret
  end

  def gwqa_form_indices_group
    mode = ''
    mode = 'date' unless @title.categoey_view
    mode = 'date' if @title.category == 0

    brk_key = nil
    ret = '<table class="index">'
    i = 0
    ret += '<tr class="headIndex">'
    ret += '<th class="docTitle">記事タイトル</th>'
    ret += '<th class="item">' + "回答数</th>"
    ret += '<th class="item">' + "状況</th>"
    ret += '<th class="category">' + "#{@title.category1_name unless @title.category1_name.blank?}</th>"  if mode.blank?
    ret += '<th class="update">' + "回答最終更新日時</th>"
    ret += "</tr>"
    for item in @items
      unless brk_key == item.section_code.to_s
        i = 0
        ret += '<tr class="subIndex">'
        ret += '<th class="docTitle">' + item.section_name.to_s + "</th>"
        ret += '<th class="item">' + "</th>"
        ret += '<th class="item">' + "</th>"
        ret += '<th class="category"></th>' if mode.blank?
        ret += '<th class="update"></th>'
        ret += "</tr>"
      end

      i += 1
      tr = (i%2 != 0) ? '<tr class="article">' : '<tr class="article cycle">'
      ret += tr.to_s
      ret += '<td class="doctitle">' + link_to(hbr(item.title), gwqa_doc_path(item,{:title_id=>item.title_id}))  + "</td>"
      ret += '<td class="qaAnswer">' + ret_answers(item.answer_count) + "</td>"
      ret += '<td class="qaSettled">' + ret_resolved(item.content_state) + "</td>"
      ret += '<td class="category">' + gwbd_category_name(@d_categories,item.category1_id) + "</td>" if mode.blank?
      s_answer = ''
      s_answer = item.latest_answer.strftime('%Y-%m-%d %H:%M').to_s unless item.latest_answer.blank?
      ret += '<td class="update">' + s_answer + "</td>"
      ret += "</tr>"
      brk_key = item.section_code.to_s
    end
    ret += "</table>"
    return ret
  end

  def gwqa_form_indices_category
    brk_key = nil
    ret = '<table class="index">' + ""
    i = 0
    ret += '<tr class="headIndex">'
    ret += '<th class="docTitle">記事タイトル</th>'
    ret += '<th class="item">' + "回答数</th>"
    ret += '<th class="item">' + "状況</th>"
    ret += '<th class="update">' + "質問登録日時</th>"
    ret += '<th class="group">' + "回答最終更新日時</th>"
    ret += "</tr>"
    for item in @items
      category_name = gwbd_category_name(@d_categories,item.category1_id)
      unless brk_key == item.category1_id.to_s
        i = 0
        ret += '<tr class="subIndex">'
        ret += '<th class="docTitle">■ ' + category_name + "</th>"
        ret += '<th class="item">' + "</th>"
        ret += '<th class="item">' + "</th>"
        ret += '<th class="update"></th>'
        ret += '<th class="group"></th>'
        ret += "</tr>"
      end

      i += 1
      tr = (i%2 != 0) ? '<tr class="article">' : '<tr class="article cycle">'
      ret += tr.to_s
      ret += '<td class="docTitle">' + link_to(hbr(item.title), gwqa_doc_path(item,{:title_id=>item.title_id})  + gwqa_params_set) + "</td>"
      ret += '<td class="qaAnswer">' + ret_answers(item.answer_count) + "</td>"
      ret += '<td class="qaSettled">' + ret_resolved(item.content_state) + "</td>"
      ret += '<td class="update">' + item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s + "</td>"
      s_answer = ''
      s_answer = item.latest_answer.strftime('%Y-%m-%d %H:%M').to_s unless item.latest_answer.blank?
      ret += '<td class="group">' + s_answer + "</td>"
      ret += "</tr>"
      brk_key = item.category1_id.to_s
    end
    ret += "</table>"
    return ret
  end
end
