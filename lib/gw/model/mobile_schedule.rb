# encoding: utf-8
module Gw::Model::MobileSchedule
  def self.show_schedule_move_core(ab, my_url, qs)
    ret = ""
    ab.each do |x|
      href = my_url.sub('%d', "#{(x[0]).strftime('%Y%m%d')}").sub('%q', "#{qs}")
      if x[1] == '前週'
        ret.concat %Q(<a href="#{href}" class="last_week">#{x[1]}</a>)
      elsif x[1] == '前日'
        ret.concat %Q(<a href="#{href}" class="yesterday">#{x[1]}</a>)
      elsif x[1] == '今日'
        ret.concat %Q(<a href="#{href}" class="today">#{x[1]}</a>)
      elsif x[1] == '翌日'
        ret.concat %Q(<a href="#{href}" class="tomorrow">#{x[1]}</a>)
      elsif x[1] == '翌週'
        ret.concat %Q(<a href="#{href}" class="following_week">#{x[1]}</a>)
      else
        ret.concat %Q(<a href="#{href}">#{x[1]}</a>)
      end
    end
    return ret
  end
end
