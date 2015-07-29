# encoding: utf-8
module Gw::MobileSchedulesHelper

  def no_schedule_show
    ret = %Q(<p class="leftPad1">予定なし</p>)
    return ret.html_safe
  end

  def no_schedule_show_smartphone
    ret = %Q(<tr><td colspan="2">予定なし</td></tr>)
    return ret.html_safe
  end

end
