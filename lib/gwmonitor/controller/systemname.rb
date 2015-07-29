# -*- encoding: utf-8 -*-
module Gwmonitor::Controller::Systemname

  def disp_system_name
    return '照会・回答システム'
  end

  def reminder_text(count)
    return %Q[<a href="/gwmonitor">照会・回答システムに未回答の記事が #{count}件 あります</a>]
  end

  def page_limit_default_setting
    params[:limit] = 100
    return if @title.blank?
    return if @title.default_limit.blank?
    params[:limit] = @title.default_limit.to_s
  end

end