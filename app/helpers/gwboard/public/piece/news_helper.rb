# -*- encoding: utf-8 -*-
module Gwboard::Public::Piece::NewsHelper

  def gwboard_news_indices_date
    brk_key = nil
    break_line = 0
    l_line = gwbbs_start_line
    ret = '<table class="bbsList">' + "\n"
    for item in @items
      break_line = break_line + 1
      break if 18 < break_line
      l_line = l_line + 1
      unless brk_key == item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s
        ret += "<tr>\n"
        ret += '<th style="width: 130px; text-align: left;">■ ' + item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s + "</th>\n"
        ret += "<tr>\n"
        ret += "<th>件名</th>\n"
        ret += '<th style="width: 170px; text-align: left;">所属' + "</th>\n"
        ret += "</tr>\n"
      end
      ret += "<tr>\n"
      ret += '<td style="text-align: center;">' + item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s + "</td>\n"
      ret += '<td style="text-align: left;">' + link_to(hbr(item.title), item.show_path + "&pp=#{l_line}" + gwbbs_params_set) + "</td>\n"
      ret += '<td style="text-align: left;">' + if item.editordivision.blank? then item.createrdivision.to_s else item.editordivision.to_s end + "</td>\n"
      ret += "</tr>\n"
      brk_key = item.latest_updated_at.strftime('%Y-%m-%d %H:%M').to_s
    end
    ret += "</table>\n"
    return ret
  end
end
