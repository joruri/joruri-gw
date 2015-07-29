# -*- encoding: utf-8 -*-
module Gwboard::ShowHelper

  def attach_use_old
    ret = true
    case @title.upload_system
    when 1..4
      ret = false
    end
    return ret
  end

  def index_special_link(link_param)
    ret = ''
    array = link_param.split(",")
    return ret unless array.count == 3
    return ret if array[2].blank?
    item = Gwbbs::Control.find_by_id(array[2])
    return ret unless item
    ret += '<td class="libraryTitle">' + link_to(item.title, item.docs_path) + '</td>'
    ret += '<td class="explanation">' + item.caption + '</td>'
    ret += '<td class="manager">' + gwbd_admin_name(item.admingrps_json,item.adms_json, item.dsp_admin_name) + '</td>'
    str_date = ''
    str_date = item.docslast_updated_at.strftime('%y-%m-%d %H:%M') if item.docslast_updated_at
    ret += '<td class="update">' + str_date + '</td>'
    return ret.html_safe
  end

  def banner_icon(icon)
    ret = ''
    return ret if icon.blank?
    ret = image_tag(icon, :alt=>'アイコン画像')
  end

  def ug_collection_select_plus_class(choices, item_name, items)
    ret  = "<select class='bgColorSelect' id='item_#{item_name}' name='item[#{item_name}]'>" + "\n"
    for item in items
      s_str = ''
      s_str = " selected='selected'" if item.color_code_hex == choices
      ret += "<option value='#{item.color_code_hex}'#{s_str} class='#{item.color_code_class}'>■ #{item.title}</option>" + "\n"
    end
    ret += "</select>" + "\n"
    return ret
  end

  def ug_collection_radio(choices, item_name, items)
    ret  = ''
    for item in items
      s_str = ''
      s_str = "checked='checked'" if item.color_code_hex.to_s == choices.to_s
      ret += "<input #{s_str} id='item_#{item_name}_#{item.id}' name='item[#{item_name}]' value='#{item.color_code_hex}' type='radio'><label for='item_#{item_name}_#{item.id}'><font color='#{item.color_code_hex}'>■</font></label>"
      ret +="　"
    end
    return ret
  end

  def gwboard_new_item
    return "/_admin/gwbbs/makers/new"
  end

  def admin_item_deletes_path
    return '/_admin/gwbbs/itemdeletes'
  end

  def admin_name(params_grps, params_adms)
    admingrps = JsonParser.new.parse(params_grps) if params_grps
    adms = JsonParser.new.parse(params_adms) if params_adms
    ret = ''
    for admingrp in admingrps
      ret = admingrp[2]
      break
    end if admingrps

    for adm in adms
      ret = adm[2]
      break
    end if adms if ret == ''
    return ret
  end

  def gwbd_admin_name(params_grps, params_adms, admin_name)
    unless admin_name.blank?
      return admin_name
    else
      admingrps = JsonParser.new.parse(params_grps) if params_grps
      adms = JsonParser.new.parse(params_adms) if params_adms
      ret = ''
      for admingrp in admingrps
        ret = admingrp[2]
        break
      end if admingrps

      for adm in adms
        ret = adm[2]
        break
      end if adms if ret == ''
      return ret
    end
  end
end
