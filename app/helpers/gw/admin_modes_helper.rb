# encoding: utf-8
module Gw::AdminModesHelper

  def mode_setting_link(item, config_mode)
    if !item.blank?
      ret = link_to "設定", edit_gw_admin_mode_path(item)
    else
      ret = link_to "設定", new_gw_admin_mode_path({:config => config_mode})
    end
    return ret.html_safe
  end
end
