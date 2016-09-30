module Gwbbs::Admin::IndicesHelper

  def gwbbs_params_set
    str = ''
    str += "&state=#{params[:state]}" unless params[:state].blank?
    str += "&cat1=#{params[:cat1]}" unless params[:cat1].blank?
    str += "&grp=#{params[:grp]}" unless params[:grp].blank?
    str += "&yyyy=#{params[:yyyy]}" unless params[:yyyy].blank?
    str += "&mm=#{params[:mm]}" unless params[:mm].blank?
    str += "&page=#{params[:page]}" unless params[:page].blank?

    unless params[:limit].to_s == @title.default_limit.to_s
      str += "&limit=#{params[:limit]}"
    end unless params[:limit].blank?
    str += "&kwd=#{CGI.escape(params[:kwd].toutf8)}" unless params[:kwd].blank?
    return str
  end

  def retstr_attache_span(attach)
    str = ''
    unless attach.blank?
      if attach.to_s != '0'
        str = "<span>#{attach.to_s}</span>"
      end
    end
    return str
  end

  def retstr_balloon_span(item)
    str = ''

    return str if item.blank?
    if item.one_line_note.to_i==1
      if item.comment.count.to_i==0
        str = %Q(<span>&nbsp;</span>)
      else
        str = %Q(<span>#{item.comment.count}</span>)
      end
    else
    end
    return str
  end

  def retstr_important_span(important)
    str = ''
    str = '<span>重要</span>' if important.to_s == '0' unless important.blank?
    return str
  end

  def retstr_colspan(title, num)
    num += 1 if title.importance == 1
    num += 1 if title.use_read_flag
    return num
  end

  def title_read_flag(title, doc)
    return "" unless title.use_read_flag
    return doc.read_flag_class
  end

  def convert_for_mobile_body(body, sid)
    Gw::Controller::Mobile.convert_for_mobile_body(body, sid, request).html_safe
  end
end
