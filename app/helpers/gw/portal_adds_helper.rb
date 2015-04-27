module Gw::PortalAddsHelper
  def display_ad(item)
    ret = ""
    if item.url.blank?
      ret = %Q(<img src="#{item.file_path}?#{item.updated_at.to_i}" alt="#{item.body}" title="#{item.body}"/>)
    else
      url = "/gw/portal_add_counts/#{item.id}/count"
      ret = %Q(<a href="#{url}" target="_blank"><img src="#{item.file_path}?#{item.updated_at.to_i}" alt="#{item.body}" title="#{item.body}" border="0"/></a>)
    end
    ret.html_safe
  end

  def nobanner_show(no_banner)
    i=1
    ret = ""
    if no_banner > 0
      while i<= no_banner do
        ret += %Q(<img src="/_common/themes/gw/files/ad/bn_170-50.gif" alt="" title=""/>)
        i = i+1
      end
    end
    ret.html_safe
  end
end
