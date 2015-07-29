module Gwfaq::Admin::Piece::MenusHelper

  def faq_list_trees(items, level_1, level_2)
    html = ""
    items.each do |item|
      categorie_1 = item.id
      categorie_2 = ""
      categorie_3 = ""
      html << faq_html_herf(categorie_1, categorie_2, categorie_3, item.name)

      if (item.children.size > 0) and (level_1.to_i == categorie_1)
        html << "<ul>\n"
        item.children.each do |item2|
          categorie_2 = item2.id
          categorie_3 = ""
          html << faq_html_herf(categorie_1, categorie_2, categorie_3, item2.name)

          if (item2.children.size > 0) and (level_2.to_i == categorie_2)
            html << "<ul>\n"
            item2.children.each do |item3|
              categorie_3 = item3.id
              html << faq_html_herf(categorie_1, categorie_2, categorie_3, item3.name)
            end
            html << "</ul>\n"
          end
        end
        html << "</ul>\n"
      end

    end

    return html
  end

private
  def faq_html_herf(cat_1, cat_2, cat_3, name)
    return "<li><a href='#{Site.current_node.public_uri}?s_category1_id=#{cat_1}&s_category2_id=#{cat_2}&s_category3_id=#{cat_3}'>#{h(name)}</a></li>\n"
  end

end
