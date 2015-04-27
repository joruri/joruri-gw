module Gw::Controller::PortalAd

  def disp_no_set(pattern)
    return if pattern.to_i == 1
    session[:ad] ||= {}
    disp_item = session[:ad]["disp_no_#{pattern}".to_sym]
    if disp_item.blank?
      disp_item = 1
    end
    limit = case pattern
    when 4
      7
    else
      2
    end
    if limit == disp_item
      ret_item = 1
    else
      ret_item = disp_item + 1
    end
    session[:ad]["disp_no_#{pattern}".to_sym] = ret_item
  end

  def get_large_ad(item, base_cond, join, order)
    session[:ad] ||= {}
    cond = "#{base_cond} and gw_portal_add_patterns.state ='enabled' and gw_portal_add_patterns.pattern = 5 and gw_portal_add_patterns.place = 3"
    large_items  = item.class.joins(join).select("gw_portal_adds.* , gw_portal_add_patterns.group_id").where(cond).order(order).all
    return nil if large_items.blank?
    limit = large_items.size
    if session[:ad][:disp_no_5_up].blank?
      session[:ad][:disp_no_5_up] = 0
      show_ad = 0
    else
      session[:ad][:disp_no_5_up] += 1
      session[:ad][:disp_no_5_up] = 0 if session[:ad][:disp_no_5_up] >= limit
      show_ad = session[:ad][:disp_no_5_up]
    end
    return_item = [large_items[show_ad]]
    return return_item
  end

  def return_limit(place,pattern)
    return if pattern.to_i == 1
    session[:ad] ||= {}
    ret = []
    addition = []
    if session[:ad]["disp_no_#{pattern}".to_sym].blank?
      disp_item = 1
      session[:ad]["disp_no_#{pattern}".to_sym] = 1
    else
      disp_item = session[:ad]["disp_no_#{pattern}".to_sym]
    end
    if place == 2
      if pattern==4
        ret = [7, 0 ]
        addition = case disp_item
        when 1
          [3,4,5,6]
        when 2
          [4,5,6,0]
        when 3
          [5,6,0,1]
        when 4
          [6,0,1,2]
        when 5
          [0,1,2,3]
        when 6
          [1,2,3,4]
        when 7
          [2,3,4,5]
        else
          [3,4,5,6]
        end
      else
        if disp_item.to_i == 1
          ret = [4, 0]
        else
          ret = [4, 4]
        end
      end
    else
      if pattern==4
        ret = [7, 0 ]
        addition = case disp_item.to_i
        when 1
          [0,1,2]
        when 2
          [1,2,3]
        when 3
          [2,3,4]
        when 4
          [3,4,5]
        when 5
          [4,5,6]
        when 6
          [5,6,0]
        when 7
          [6,0,1]
        else
          [1,2,3]
        end
      else
        if disp_item == 1
          ret = [3, 0]
        else
          ret = [3, 3]
        end
      end
    end
    return [ret, addition]
  end
end