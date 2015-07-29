# -*- encoding: utf-8 -*-
module Gwfaq::Admin::IndicesHelper

  def gwfaq_params_set
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

  def gwfaq_form_indices
    ret = ""
    case params[:state]
    when "TODAY"
      ret = gwfaq_form_indices_date
    when "DATE"
      ret = gwfaq_form_indices_date
    when "GROUP"
      ret = gwfaq_form_indices_group
    when "CATEGORY"
      ret = gwfaq_form_indices_category
    else
      ret = gwfaq_form_indices_date
    end
    return ret.html_safe
  end

  def gwfaq_start_line
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

  def gwfaq_form_indices_date
    brk_key = nil
    l_line = gwfaq_start_line
    ret = '<table class="index">'
    i = 0
    ret += '<tr class="headIndex">'
    ret += '<th class="docTitle">記事タイトル</th>'
    ret += '<th class="category">' + "#{@title.category1_name unless @title.category1_name.blank?}</th>"
    ret += '<th class="update">' + "最終更新日時</th>"
    ret += "</tr>"
    for item in @items
      unless brk_key == item.latest_updated_at.strftime('%Y-%m-%d').to_s
        i = 0
        ret += '<tr class="subIndex">'
        ret += '<th class="docTitle">■ ' + item.latest_updated_at.strftime('%Y-%m-%d').to_s  + "</th>"
        ret += '<th class="category"></th>'
        ret += '<th class="update"></th>'
        ret += "</tr>"
      end

      i += 1
      tr = (i%2 != 0) ? '<tr class="article">' : '<tr class="article cycle">'
      l_line = l_line + 1
      ret += tr.to_s
      ret += '<td class="docTitle ">' + link_to(hbr(item.title), gwfaq_doc_path(item,{:title_id=>item.title_id})  + "&pp=#{l_line}" + gwfaq_params_set) +  "</td>"
      ret += '<td class="category">' + gwbd_category_name(@d_categories,item.category1_id) + "</td>"
      ret += '<td class="update">' + item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s + "</td>"
      ret += "</tr>"
      brk_key = item.latest_updated_at.strftime('%Y-%m-%d').to_s
    end
    ret += "</table>"
    return ret
  end

  def gwfaq_form_indices_category
    brk_key = nil
    l_line = gwfaq_start_line
    ret = '<table class="index">' + ""
    i = 0
    ret += '<tr class="headIndex">'
    ret += '<th class="docTitle">記事タイトル</th>'
    ret += '<th class="update">' + "最終更新日時</th>"
    ret += "</tr>"
    for item in @items
      l_line = l_line + 1
      category_name = gwbd_category_name(@d_categories,item.category1_id)
      unless brk_key == item.category1_id.to_s
        i = 0
        ret += '<tr class="subIndex">'
        ret += '<th class="docTitle">■ ' + category_name + "</th>"
        ret += '<th class="update"></th>'
        ret += "</tr>"
      end

      i += 1
      tr = (i%2 != 0) ? '<tr class="article">' : '<tr class="article cycle">'
      l_line = l_line + 1
      ret += tr.to_s
      ret += '<td class="docTitle ">' + link_to(hbr(item.title), gwfaq_doc_path(item,{:title_id=>item.title_id}) + "&pp=#{l_line}" + gwfaq_params_set)  + "</td>"
      ret += '<td class="update">' + item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s + "</td>"
      ret += "</tr>"
      brk_key = item.category1_id.to_s
    end
    ret += "</table>"
    return ret
  end

  def gwfaq_form_indices_group
    brk_key = nil
    l_line = gwfaq_start_line
    ret = '<table class="index">'
    i = 0
    ret += '<tr class="headIndex">'
    ret += '<th class="docTitle">記事タイトル</th>'
    ret += '<th class="category">' + "#{@title.category1_name unless @title.category1_name.blank?}</th>"
    ret += '<th class="update">' + "最終更新日時</th>"
    ret += "</tr>"
    for item in @items
      unless brk_key == item.section_code.to_s
        i = 0
        ret += '<tr class="subIndex">'
        ret += '<th class="docTitle">' + item.section_name.to_s + "</th>"
        ret += '<th class="category"></th>'
        ret += '<th class="update"></th>'
        ret += "</tr>"
      end
      l_line = l_line + 1

      i += 1
      tr = (i%2 != 0) ? '<tr class="article">' : '<tr class="article cycle">'
      l_line = l_line + 1
      ret += tr.to_s
      ret += '<td class="doctitle ">' + link_to(hbr(item.title), gwfaq_doc_path(item,{:title_id=>item.title_id}) + "&pp=#{l_line}&grp=#{params[:grp]}" + gwfaq_params_set) + "</td>"
      ret += '<td class="category">' + gwbd_category_name(@d_categories,item.category1_id) + "</td>"
      ret += '<td class="update">' + item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s + "</td>"
      ret += "</tr>"
      brk_key = item.section_code.to_s
    end
    ret += "</table>"
    return ret
  end

  def gwfaq_admin_form_indices_date
    l_line = gwbbs_start_line
    ret = '<table class="index">' + "\n"
    ret += "<tr>\n"
    ret += '<th style="width: 60px; text-align: center;">状態' + "</th>\n"
    ret += '<th style="width: 120px; text-align: center;">最終更新日' + "</th>\n"
    ret += "<th>件名</th>\n"
    ret += '<th style="width: 170px; text-align: left;">所属' + "</th>\n"
    ret += "</tr>\n"
    for item in @items
      l_line = l_line + 1
      ret += "<tr>\n"
      ret += '<td style="text-align: center;">' + link_to(item.ststus_name, gwfaq_doc_path(item,{:title_id=>item.title_id}) + "&pp=#{l_line}" + gwbbs_params_set) + "</td>\n"
      ret += '<td style="text-align: center;">' + item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s + "</td>\n"
      ret += '<td style="text-align: left;">' + link_to(hbr(item.title), item.show_path + "&pp=#{l_line}" + gwbbs_params_set) + "</td>\n"
      ret += '<td style="text-align: left;">' + if item.editordivision.blank? then item.createrdivision.to_s else item.editordivision.to_s end + "</td>\n"
      ret += "</tr>\n"
    end
    ret += "</table>\n"
    return ret
  end

end
