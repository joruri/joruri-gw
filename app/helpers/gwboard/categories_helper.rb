module Gwboard::CategoriesHelper

  def link_to_list_gwboard_category(item)
    ret = link_to '展開', url_for(item.link_list_path)
    return ret.html_safe
  end

  def gwbd_category_name(items, choice)
    begin
      ret = items[choice][:name]
    rescue
      ret = ''
    end
    return ret.html_safe
  end
end
