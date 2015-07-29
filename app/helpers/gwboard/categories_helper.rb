# -*- encoding: utf-8 -*-
module Gwboard::CategoriesHelper

  def link_to_list_gwboard_category(item)
    ret = link_to '展開', url_for(item.link_list_path)
    return ret.html_safe
  end

  def gwbd_public_url_base
    return Core.request_uri.chop + "?title_id=" + params[:title_id].to_s
  end

  def gwbd_category_name(items, choice)
    begin
      ret = items[choice][:name]
    rescue
      ret = ''
    end
    return ret.html_safe
  end

  def gwbd_category_count(choice)
    item = @base_item.new
    sel_cond = "title_id=#{@title.id} and state='public' and category1_id=#{choice}"
    sel_cond << " and ('#{Time.now.strftime('%Y-%m-%d %H:%M')}:00' BETWEEN able_date AND expiry_date)"
    cats_count = item.count(:all,:conditions=>sel_cond)
    ret = cats_count
    return ret
  end

  def gwqa_category_count(choice)
    item = @base_item.new
    sel_cond = "title_id=#{params[:title_id]} and state='public' and category1_id=#{choice}"
    cats_count = item.count(:all,:conditions=>sel_cond)
    ret = cats_count
    return ret
  end

  def gwbd_group_name_by_code(items, choice)
    ret = nil
    for item in items
      if item.code == choice.section_code
        ret = item.name.to_s
      end
    end
    ret = choice.section_name if ret.blank?
    ret = '所属登録なし' if ret.blank?
    return ret
  end
end
