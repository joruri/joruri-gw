module Gwboard::ShowHelper

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
end
