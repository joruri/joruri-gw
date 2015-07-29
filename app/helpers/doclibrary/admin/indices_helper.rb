# -*- encoding: utf-8 -*-
module Doclibrary::Admin::IndicesHelper

  def doclib_params_set_index
    ret = ""
    ret += "&state=#{params[:state]}" unless params[:state].blank?
    ret += "&gcd=#{params[:gcd]}" unless params[:gcd].blank?
    ret += "&cat=#{params[:cat]}" unless params[:cat].blank?
    ret += "&page=#{params[:page]}" unless params[:page].blank?
    ret += "&limit=#{params[:limit]}" unless params[:limit].blank?
    ret += "&kwd=#{URI.encode(params[:kwd])}" unless params[:kwd].blank?
    return ret
  end

  def doclib_params_set
    ret = ""
    ret += "&state=#{params[:state]}" unless params[:state].blank?
    ret += "&gcd=#{params[:gcd]}" unless params[:gcd].blank?
    ret += "&cat=#{params[:cat]}" unless params[:cat].blank?
    ret += "&page=#{params[:page]}" unless params[:page].blank?
    ret += "&limit=#{params[:limit]}" unless params[:limit].blank?
    ret += "&kwd=#{URI.encode(params[:kwd])}" unless params[:kwd].blank?
    return ret
  end

  def doclib_form_indices
    ret = ""
    case params[:state]
    when "TODAY"
      ret = doclib_form_indices_date
    when "DATE"
      ret = doclib_form_indices_date
    when "GROUP"
      ret = doclib_form_indices_group
    when "CATEGORY"
      ret = doclib_form_indices_category
    else
      ret = doclib_form_indices_date
    end
    return ret.html_safe
  end

  def doclib_start_line
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

  def retstr_attache(attach)
    str = ''
    unless attach.blank?
      if attach.to_s != '0'
        str = 'class="bbsAttach"'
      end
    end
    return str
  end

  def retstr_balloon(balloon)
    str = ''
    str = 'class="bbsBalloon"' if balloon.to_s == '1' unless balloon.blank?
    return str
  end

  def retstr_important(important)
    str = ''
    str = 'class="bbsImportant"' if important.to_s == '0' unless important.blank?
    return str
  end

  def doclib_form_indices_date
    brk_key = nil
    l_line = doclib_start_line
    ret = ' <table class="docformTitle">' + "\n"
    for item in @items
      unless brk_key == item.latest_updated_at.strftime('%Y-%m-%d').to_s
        ret += "<tr>\n"
        ret += '<th style="width: 3px; text-align: center;">' + "</th>\n" if @title.importance.to_s == '1'
        ret += '<th style="width: 3px; text-align: center;">' + "</th>\n"
        ret += '<th style="width: 3px; text-align: center;">' + "</th>\n"
        ret += '<th style="text-align: left;">■ ' + item.latest_updated_at.strftime('%Y-%m-%d').to_s  + "</th>\n"
        ret += '<th style="width: 170px; text-align: left;">' + "</th>\n"
        ret += "</tr>\n"
      end
      l_line = l_line + 1
      ret += "<tr>\n"
      ret += '<td ' + retstr_important(item.importance) + 'style="text-align: center;">' + "</td>\n" if @title.importance.to_s == '1'
      ret += '<td ' + retstr_attache(item.attachmentfile) + 'style="text-align: center;">' + "</td>\n"
      ret += '<td ' + retstr_balloon(item.one_line_note)  + 'style="text-align: center;">' + "</td>\n"
      ret += '<td style="text-align: left;">' + link_to(hbr(item.title), item.show_path(params[:state]) + "&pp=#{l_line}" + doclib_params_set) + "</td>\n"
      ret += '<td style="text-align: left;">' + if item.editordivision.blank? then item.createrdivision.to_s else item.editordivision.to_s end + "</td>\n"
      ret += "</tr>\n"
      brk_key = item.latest_updated_at.strftime('%Y-%m-%d').to_s
    end
    ret += "</table>\n"
    return ret
  end

  def doclib_form_indices_group
    brk_key = nil
    l_line = doclib_start_line
    ret = '<table class="docformTitle">' + "\n"
    for item in @items
      unless brk_key == item.createrdivision.to_s
        ret += "<tr>\n"
        ret += '<th style="width: 3px; text-align: center;">' + "</th>\n" if @title.importance.to_s == '1'
        ret += '<th style="width: 3px; text-align: center;">' + "</th>\n"
        ret += '<th style="width: 3px; text-align: center;">' + "</th>\n"
        ret += '<th style="text-align: left;">' + item.createrdivision.to_s + "</th>\n"
        ret += '<th style="width: 130px; text-align: center;">最終更新日時' + "</th>\n"
        ret += "</tr>\n"
      end
      l_line = l_line + 1
      ret += "<tr>\n"
      ret += '<td ' + retstr_important(item.importance) + 'style="text-align: center;">' + "</td>\n" if @title.importance.to_s == '1'
      ret += '<td ' + retstr_attache(item.attachmentfile) + 'style="text-align: center;">' + "</td>\n"
      ret += '<td ' + retstr_balloon(item.one_line_note)  + 'style="text-align: center;">' + "</td>\n"
      ret += '<td style="text-align: left;">' + link_to(hbr(item.title), item.show_path(params[:state]) + "&pp=#{l_line}&grp=#{params[:grp]}" + doclib_params_set) + "</td>\n"
      ret += '<td style="text-align: center;">' + item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s + "</td>\n"
      ret += "</tr>\n"
      brk_key = item.createrdivision.to_s
    end
    ret += "</table>\n"
    return ret
  end

  def doclib_form_indices_category
    brk_key = nil
    l_line = doclib_start_line
    ret = '<table class="docformTitle">' + "\n"
    for item in @items
      l_line = l_line + 1
      category_name = gwbd_category_name(@categories1,item.category1_id)
      unless brk_key == item.category1_id.to_s
        ret += "<tr>\n"
        ret += '<th style="width: 3px; text-align: center;">' + "</th>\n" if @title.importance.to_s == '1'
        ret += '<th style="width: 3px; text-align: center;">' + "</th>\n"
        ret += '<th style="width: 3px; text-align: center;">' + "</th>\n"
        ret += '<th style="width: 130px; text-align: left;">■ ' + category_name + "</th>\n"
        ret += "<th></th>\n"
        ret += '<th style="width: 170px; text-align: left;">' + "</th>\n"
        ret += "</tr>\n"
      end
      ret += "<tr>\n"
      ret += '<td ' + retstr_important(item.importance) + 'style="text-align: center;">' + "</td>\n" if @title.importance.to_s == '1'
      ret += '<td ' + retstr_attache(item.attachmentfile) + 'style="text-align: center;">' + "</td>\n"
      ret += '<td ' + retstr_balloon(item.one_line_note)  + 'style="text-align: center;">' + "</td>\n"
      ret += '<td style="text-align: left;">' + item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s + "</td>\n"
      ret += '<td style="text-align: left;">' + link_to(hbr(item.title), item.show_path(params[:state]) + "&pp=#{l_line}" + doclib_params_set) + "</td>\n"
      ret += '<td style="text-align: left;">' + if item.editordivision.blank? then item.createrdivision.to_s else item.editordivision.to_s end + "</td>\n"
      ret += "</tr>\n"
      brk_key = item.category1_id.to_s
    end
    ret += "</table>\n"
    return ret
  end

  def doclib_admin_form_indices_date
    l_line = doclib_start_line
    ret = '<table class="docformTitle">' + "\n"
    ret += "<tr>\n"
    ret += '<th style="width: 60px; text-align: center;">状態' + "</th>\n"
    ret += '<th style="width: 130px; text-align: center;">最終更新日時' + "</th>\n"
    ret += "<th>件名</th>\n"
    ret += '<th style="width: 170px; text-align: left;">所属' + "</th>\n"
    ret += "</tr>\n"
    for item in @items
      l_line = l_line + 1
      ret += "<tr>\n"
      ret += '<td style="text-align: center;">' + link_to(item.ststus_name, item.show_path(params[:state]) + "&pp=#{l_line}" + doclib_params_set) + "</td>\n"
      ret += '<td style="text-align: center;">' + item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s + "</td>\n"
      ret += '<td style="text-align: left;">' + link_to(hbr(item.title), item.show_path(params[:state]) + "&pp=#{l_line}" + doclib_params_set) + "</td>\n"
      ret += '<td style="text-align: left;">' + if item.editordivision.blank? then item.createrdivision.to_s else item.editordivision.to_s end + "</td>\n"
      ret += "</tr>\n"
    end
    ret += "</table>\n"
    return ret
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

end
