# encoding: utf-8
module Gwbbs::Admin::IndicesHelper

  def gwbbs_params_set
    str = ''
    str += "&state=#{params[:state]}" unless params[:state].blank?
    str += "&cat1=#{params[:cat1]}" unless params[:cat1].blank?
    str += "&grp=#{params[:grp]}" unless params[:grp].blank?
    str += "&yyyy=#{params[:yyyy]}" unless params[:yyyy].blank?
    str += "&mm=#{params[:mm]}" unless params[:mm].blank?
    str += "&page=#{params[:page]}" unless params[:page].blank?

    unless params[:limit].to_s == @title.default_limit.to_s
      str += "&limit=#{params[:limit]}"
    end unless params[:limit].blank?
    str += "&kwd=#{CGI.escape(params[:kwd].toutf8)}" unless params[:kwd].blank?
    return str
  end

  def gwbbs_form_indices
    ret = ""
    case params[:state]
    when "TODAY"
      ret = gwbbs_form_indices_date
    when "DATE"
      ret = gwbbs_form_indices_date
    when "GROUP"
      ret = gwbbs_form_indices_group
    when "CATEGORY"
      ret = gwbbs_form_indices_category
    else
      ret = gwbbs_form_indices_date
    end
    return ret.html_safe
  end

  def gwbbs_mobile_form_indices
    ret = gwbbs_form_indices_mobile
    return ret.html_safe
  end

  def gwbbs_smartphone_form_indices
    ret = ""
    case params[:state]
    when "TODAY"
      ret = gwbbs_form_indices_date_smartphone
    when "DATE"
      ret = gwbbs_form_indices_date_smartphone
    when "GROUP"
      ret = gwbbs_form_indices_group_smartphone
    when "CATEGORY"
      ret = gwbbs_form_indices_category_smartphone
    else
      ret = gwbbs_form_indices_date_smartphone
    end
    return ret.html_safe
  end

  def gwbbs_start_line
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

  def retstr_attache_span(attach)
    str = ''
    unless attach.blank?
      if attach.to_s != '0'
        str = "<span>#{attach.to_s}</span>"
      end
    end
    return str
  end

  def retstr_balloon_span(item)
    str = ''

    return str if item.blank?
    if item.one_line_note.to_i==1
      if item.comment.count.to_i==0
        str = %Q(<span>&nbsp;</span>)
      else
        str = %Q(<span>#{item.comment.count}</span>)
      end
    else
    end
    return str
  end

  def retstr_important_span(important)
    str = ''
    str = '<span>重要</span>' if important.to_s == '0' unless important.blank?
    return str
  end

  def ret_str_search_title_lbl
    str = ''
    str = '<h4 class="docSearchTitle">検索結果（タイトル・本文）</h4>' unless params[:kwd].blank?
    return str
  end

  def gwbbs_form_indices_date
    doc_title = ''
    doc_title = '記事件名'   unless @title.form_name == 'form009'
    doc_title = 'システム名' if @title.form_name == 'form009'
    i = 0
    brk_key = nil
    ret = ret_str_search_title_lbl
    ret += '<table class="index">'
    ret += '<tr class="headIndex">'
    ret += '<th class="item">' + "</th>" if @title.importance.to_s == '1'
    ret += '<th class="docTitle">' + doc_title + '</th>'
    ret += '<th class="item">' + "</th>"
    ret += '<th class="item">' + "</th>"
    ret += '<th class="group">' + "記事管理所属</th>"
    ret += '<th class="update">' + "最終更新日時</th>"
    ret += "</tr>"
    for item in @items
      unless brk_key == item.latest_updated_at.strftime('%Y-%m-%d').to_s
        i = 0
        ret += '<tr class="subIndex">'
        ret += '<th colspan="6" class="docTitle">' + item.latest_updated_at.strftime('%Y-%m-%d').to_s  + "</th>" if @title.importance.to_s == '1'
        ret += '<th colspan="5" class="docTitle">' + item.latest_updated_at.strftime('%Y-%m-%d').to_s  + "</th>" unless @title.importance.to_s == '1'
        ret += "</tr>"
      end

      new_mark_str = ''
      if @title.id == 1
        if item.new_mark_flg
          new_mark_str  = %Q(<span class="new">new</span>)
        else
          #new_mark_str  = %Q(<span></span>)
        end
      else
      end

      i += 1
      tr = (i%2 != 0) ? '<tr class="article">' : '<tr class="article cycle">'
      ret += tr.to_s
      ret += '<td class="bbsImportant" style="text-align: center;">' + retstr_important_span(item.importance) + "</td>" if @title.importance.to_s == '1'
      ret += '<td class="docTitle">' + link_to(hbr(item.title), item.show_path  + gwbbs_params_set) + new_mark_str +  "</td>"
      ret += '<td class="bbsAttach" >' + retstr_attache_span(item.attachmentfile) + "</td>"
      ret += '<td class="bbsBalloon">' + retstr_balloon_span(item)  +  "</td>"
      ret += '<td class="group">' + link_to(item.section_name.to_s, "#{@title.docs_path}&state=GROUP&grp=#{item.section_code}") + "</td>"
      ret += '<td class="update">' + item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s + "</td>"
      ret += "</tr>"
      brk_key = item.latest_updated_at.strftime('%Y-%m-%d').to_s
    end
    ret += "</table>"
    return ret
  end

  def gwbbs_form_indices_group
    mode = ''
    mode = 'date' unless @title.categoey_view
    mode = 'date' if @title.category == 0
    doc_title = ''
    doc_title = '記事件名'   unless @title.form_name == 'form009'
    doc_title = 'システム名' if @title.form_name == 'form009'
    i = 0
    brk_key = nil
    ret = ret_str_search_title_lbl
    ret += '<table class="index">'
    ret += '<tr class="headIndex">'
    ret += '<th class="item">' + "</th>" if @title.importance.to_s == '1'
    ret += '<th class="docTitle">' + doc_title + '</th>'
    ret += '<th class="item">' + "</th>"
    ret += '<th class="item">' + "</th>"
    if mode.blank?
      ret += '<th class="category">' + "#{@title.category1_name unless @title.category1_name.blank?}</th>"
    else
      ret += '<th class="update">' + "登録日時</th>"
    end
    ret += '<th class="update">' + "最終更新日時</th>"
    ret += "</tr>"
    for item in @items
      unless brk_key == item.section_code.to_s
        i = 0
        ret += '<tr class="subIndex">'
        ret += '<th colspan="6" class="docTitle">' + item.section_name.to_s + "</th>" if @title.importance.to_s == '1'
        ret += '<th colspan="5" class="docTitle">' + item.section_name.to_s + "</th>" unless @title.importance.to_s == '1'
        ret += "</tr>"
      end

      new_mark_str = ''
      if @title.id == 1
        if item.new_mark_flg
          new_mark_str  = %Q(<span class="new">new</span>)
        else
          #new_mark_str  = %Q(<span></span>)
        end
      else
      end

      i += 1
      tr = (i%2 != 0) ? '<tr class="article">' : '<tr class="article cycle">'
      ret += tr.to_s
      ret += '<td class="bbsImportant" style="text-align: center;">' + retstr_important_span(item.importance) + "</td>" if @title.importance.to_s == '1'
      ret += '<td class="docTitle">' + link_to(hbr(item.title), item.show_path  + gwbbs_params_set) + new_mark_str + "</td>"
      ret += '<td class="bbsAttach" >' + retstr_attache_span(item.attachmentfile) + "</td>"
      ret += '<td class="bbsBalloon">' + retstr_balloon_span(item)  +  "</td>"
      if mode.blank?
        ret += '<td class="category">' + gwbd_category_name(@d_categories,item.category1_id) + "</td>"
      else
        ret += '<td class="update">' + item.created_at.strftime('%Y-%m-%d %H:%M').to_s + "</td>"
      end
      ret += '<td class="update">' + item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s + "</td>"
      ret += "</tr>"
      brk_key = item.section_code.to_s
    end
    ret += "</table>"
    return ret
  end

  def gwbbs_form_indices_category
    doc_title = ''
    doc_title = '記事件名'   unless @title.form_name == 'form009'
    doc_title = 'システム名' if @title.form_name == 'form009'
    i = 0
    brk_key = nil
    ret = ret_str_search_title_lbl
    ret += '<table class="index">' + ""
    ret += '<tr class="headIndex">'
    ret += '<th class="item">' + "</th>" if @title.importance.to_s == '1'
    ret += '<th class="docTitle">' + doc_title + '</th>'
    ret += '<th class="item">' + "</th>"
    ret += '<th class="item">' + "</th>"
    ret += '<th class="group">' + "記事管理所属</th>"
    ret += '<th class="update">' + "最終更新日時</th>"
    ret += "</tr>"
    for item in @items
      category_name = gwbd_category_name(@d_categories,item.category1_id)
      unless brk_key == item.category1_id.to_s
        i = 0
        ret += '<tr class="subIndex">'
        ret += '<th colspan="6" class="docTitle">' + category_name + "</th>" if @title.importance.to_s == '1'
        ret += '<th colspan="5" class="docTitle">' + category_name + "</th>" unless @title.importance.to_s == '1'
        ret += "</tr>"
      end

      new_mark_str = ''
      if @title.id == 1
        if item.new_mark_flg
          new_mark_str  = %Q(<span class="new">new</span>)
        else
          #new_mark_str  = %Q(<span></span>)
        end
      else
      end

      i += 1
      tr = (i%2 != 0) ? '<tr class="article">' : '<tr class="article cycle">'
      ret += tr.to_s
      ret += '<td  class="bbsImportant" style="text-align: center;">' + retstr_important_span(item.importance) + "</td>" if @title.importance.to_s == '1'
      ret += '<td class="docTitle ">' + link_to(hbr(item.title), item.show_path  + gwbbs_params_set) + new_mark_str + "</td>"
      ret += '<td class="bbsAttach ">' + retstr_attache_span(item.attachmentfile) + "</td>"
      ret += '<td class="bbsBalloon">' + retstr_balloon_span(item)  + "</td>"
      ret += '<td class="group">' + link_to(item.section_name.to_s, "#{@title.docs_path}&state=GROUP&grp=#{item.section_code}") + "</td>"
      ret += '<td class="update">' + item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s + "</td>"
      ret += "</tr>"
      brk_key = item.category1_id.to_s
    end
    ret += "</table>"
    return ret
  end

  def gwbbs_admin_form_indices_date
    i = 0
    ret = ret_str_search_title_lbl
    ret += '<table class="index">' + ""
    ret += "<tr>"
    ret += '<th class="state">状態' + "</th>"
    ret += '<th class="update">最終更新日時' + "</th>"
    ret += '<th class="doctitle">件名</th>'
    ret += '<th class="group">所属' + "</th>"
    ret += "</tr>"
    for item in @items
      i += 1
      tr = (i%2 != 0) ? '<tr class="article">' : '<tr class="article cycle">'
      ret += tr.to_s
      ret += '<td class="state">' + link_to(item.ststus_name, item.show_path  + gwbbs_params_set) + "</td>"
      ret += '<td class="update">' + item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s + "</td>"
      if item.title.blank?
        ret += '<td class="docTitle ">' + link_to('タイトルが登録されていません', item.show_path  + gwbbs_params_set) + "</td>"
      else
        ret += '<td class="docTitle ">' + link_to(hbr(item.title), item.show_path  + gwbbs_params_set) + "</td>"
      end
      ret += '<td class="group">' + item.section_name.to_s + "</td>"
      ret += "</tr>"
    end
    ret += "</table>"
    return ret
  end

  def gwbbs_form_indices_mobile
    i = 0
    brk_key = nil
    ret = ret_str_search_title_lbl
    for item in @items
      unless brk_key == item.latest_updated_at.strftime('%Y-%m-%d').to_s
        i = 0
        ret += '<p class="bgAsh">'
        ret += item.latest_updated_at.strftime('%Y-%m-%d').to_s + "<br />"  if @title.importance.to_s == '1'
        ret += item.latest_updated_at.strftime('%Y-%m-%d').to_s + "<br />"  unless @title.importance.to_s == '1'
        ret += '</p>'
      end

      i += 1
      ret += "・"
      ret += link_to(hbr(item.title), item.show_path  + gwbbs_params_set)
      ret += "<br />"

      brk_key = item.latest_updated_at.strftime('%Y-%m-%d').to_s
    end

    return ret
  end

  def convert_for_mobile_body(body,sid)
    ret = Gw::Controller::Mobile.convert_for_mobile_body(body, sid)
    return ret.html_safe
  end


  def gwbbs_form_indices_date_smartphone
    i = 0
    brk_key = nil
    ret = ""
    ret += '<table class="index">'
    for item in @items
      unless brk_key == item.latest_updated_at.strftime('%Y-%m-%d').to_s
        i = 0
        ret += '<tr class="subIndex">'
        ret += '<th colspan="2" class="docTitle">' + item.latest_updated_at.strftime('%Y-%m-%d').to_s  + "</th>" if @title.importance.to_s == '1'
        ret += '<th colspan="1" class="docTitle">' + item.latest_updated_at.strftime('%Y-%m-%d').to_s  + "</th>" unless @title.importance.to_s == '1'
        ret += "</tr>"
      end

      new_mark_str = ''
      if @title.id == 1
        if item.new_mark_flg
          new_mark_str  = %Q(<span class="new">new</span>)
        else
          #
        end
      else
      end

      i += 1
      tr = (i%2 != 0) ? '<tr class="article">' : '<tr class="article cycle">'
      ret += tr.to_s
      title_class=""
      if @title.importance.to_s == '1'
        ret += '<td class="bbsImportant leftLine" style="text-align: center;" rowspan="2">' + retstr_important_span(item.importance) + "</td>"
      else
        title_class = " leftLine"
      end
      doc_title_line = %Q(#{hbr(item.title)})
      doc_title_line += new_mark_str
      ret += %Q(<td class="docTitle#{title_class}">) + link_to(doc_title_line.html_safe , item.show_path  + gwbbs_params_set)
      #ret +=
      ret += "</td>"
      ret += "</tr><tr>"
      disp_section_name = item.section_name.to_s.sub(/([0-9]*)(.*)/i, '\2')
      grp_docs_lnk = "#{@title.docs_path}&state=GROUP&grp=#{item.section_code}" + gwbbs_params_set
      ret += %Q(<td class="group#{title_class}"><span>) + link_to(disp_section_name, grp_docs_lnk) + "</span></td>"
      ret += "</tr>"
      brk_key = item.latest_updated_at.strftime('%Y-%m-%d').to_s
    end
    ret += "</table>"
    return ret
  end

  def gwbbs_form_indices_group_smartphone
    mode = ''
    mode = 'date' unless @title.categoey_view
    mode = 'date' if @title.category == 0
    i = 0
    brk_key = nil
    ret = ""
    ret += '<table class="index">'
    for item in @items
      unless brk_key == item.section_code.to_s
        i = 0
        ret += '<tr class="subIndex">'
        ret += '<th colspan="2" class="docTitle">' + item.section_name.to_s + "</th>" if @title.importance.to_s == '1'
        ret += '<th colspan="1" class="docTitle">' + item.section_name.to_s + "</th>" unless @title.importance.to_s == '1'
        ret += "</tr>"
      end

      new_mark_str = ''
      if @title.id == 1
        if item.new_mark_flg
          new_mark_str  = %Q(<span class="new">new</span>)
        else
          #
        end
      else
      end

      i += 1
      tr = (i%2 != 0) ? '<tr class="article">' : '<tr class="article cycle">'
      ret += tr.to_s
      title_class=""
      if @title.importance.to_s == '1'
        ret += '<td class="bbsImportant leftLine" style="text-align: center;" rowspan="2">' + retstr_important_span(item.importance) + "</td>"
      else
        title_class = " leftLine"
      end
      doc_title_line = %Q(#{hbr(item.title)})
      doc_title_line += new_mark_str
      ret += %Q(<td class="docTitle#{title_class}">) + link_to(doc_title_line.html_safe, item.show_path  + gwbbs_params_set)+ "</td>"
      ret += "</tr><tr>"
      if mode.blank?
        ret += %Q(<td class="category group#{title_class}"><span>) + gwbd_category_name(@d_categories,item.category1_id) + "</span></td>"
      else
        ret += %Q(<td class="update group#{title_class}"><span>) + item.created_at.strftime('%Y-%m-%d %H:%M').to_s + "</span></td>"
      end
      ret += "</tr>"
      brk_key = item.section_code.to_s
    end
    ret += "</table>"
    return ret
  end


  def gwbbs_form_indices_category_smartphone
    i = 0
    brk_key = nil
    ret = ""
    ret += '<table class="index">' + ""
    ret += "</tr>"
    for item in @items
      category_name = gwbd_category_name(@d_categories,item.category1_id)
      unless brk_key == item.category1_id.to_s
        i = 0
        ret += '<tr class="subIndex">'
        ret += '<th colspan="2" class="docTitle">' + category_name + "</th>" if @title.importance.to_s == '1'
        ret += '<th colspan="1" class="docTitle">' + category_name + "</th>" unless @title.importance.to_s == '1'
        ret += "</tr>"
      end

      new_mark_str = ''
      if @title.id == 1
        if item.new_mark_flg
          new_mark_str  = %Q(<span class="new">new</span>)
        else
          #
        end
      else
      end

      i += 1
      tr = (i%2 != 0) ? '<tr class="article">' : '<tr class="article cycle">'
      ret += tr.to_s
      title_class=""
      if @title.importance.to_s == '1'
        ret += '<td class="bbsImportant leftLine" style="text-align: center;" rowspan="2">' + retstr_important_span(item.importance) + "</td>"
      else
        title_class = " leftLine"
      end
      doc_title_line = %Q(#{hbr(item.title)})
      doc_title_line += new_mark_str
      ret += %Q(<td class="docTitle#{title_class}">) + link_to(doc_title_line.html_safe, item.show_path  + gwbbs_params_set) + "</td>"
      ret += "</tr><tr>"
      ret += %Q(<td class="group#{title_class}"><span>) + item.section_name.to_s + "</span></td>"
      ret += "</tr>"
      brk_key = item.category1_id.to_s
    end
    ret += "</table>"
    return ret
  end

  def gwbbs_admin_form_indices_date_smartphone
    i = 0
    ret = ""
    ret += '<table class="index">' + ""
    ret += "<tr>"
    ret += '<th class="state">状態' + "</th>"
    ret += '<th class="doctitle">件名</th>'
    ret += '<th class="group">所属' + "</th>"
    ret += "</tr>"
    for item in @items
      i += 1
      tr = (i%2 != 0) ? '<tr class="article">' : '<tr class="article cycle">'
      ret += tr.to_s
      ret += '<td class="state leftLine">' + link_to(item.ststus_name, item.show_path  + gwbbs_params_set) + "</td>"
      ret += '<td class="update">' + item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s + "</td>"
      if item.title.blank?
        ret += '<td class="docTitle ">' + link_to('タイトルが登録されていません', item.show_path  + gwbbs_params_set) + "</td>"
      else
        ret += '<td class="docTitle ">' + link_to(hbr(item.title), item.show_path  + gwbbs_params_set) + "</td>"
      end
      ret += '<td class="group">' + item.section_name.to_s + "</td>"
      ret += "</tr>"
    end
    ret += "</table>"
    return ret
  end

end
