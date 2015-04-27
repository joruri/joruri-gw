module Gw::MobileSchedulesHelper

  def grouop_enabled_children(parent_id)
    ret = System::Group.where("parent_id = ? AND state = ?",parent_id,"enabled").order(sort_no)
    return ret
  end

  def no_schedule_show
    ret = %Q(<p class="leftPad1">予定なし</p>)
    return ret.html_safe
  end

  def no_schedule_show_smartphone
    ret = %Q(<tr><td colspan="2">予定なし</td></tr>)
    return ret.html_safe
  end

end
