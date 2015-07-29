# -*- encoding: utf-8 -*-
class Gwqa::Admin::Piece::GwqaBreadCrumbsController < ApplicationController

  def index
    skip_layout
    index_core Gwqa::Doc.new
  end

  def index_core(item)
    unless params[:name].blank?
      item.and :name, params[:name]

      @cl1 = ""
      if bread_item = item.find(:first)

        bread_crumbs1 = []
        bread_crumbs1 << bread_item.item_path + "&s_category1_id=#{bread_item.category1_id}&s_category2_id=&s_category3_id="
        bread_crumbs1 << bread_item.item_path + "&s_category1_id=#{bread_item.category1_id}&s_category2_id=#{bread_item.category2_id}&s_category3_id="
        bread_crumbs1 << bread_item.item_path + "&s_category1_id=#{bread_item.category1_id}&s_category2_id=#{bread_item.category2_id}&s_category3_id=#{bread_item.category3_id}"

        unless bread_item.category1_id.blank?
          unless bread_item.category1.blank?
            @cl1 << ' > '
            @cl1 << "<a href='#{bread_crumbs1[0]}'>#{bread_item.category1.name}</a>"
          end
          unless bread_item.category2.blank?
            @cl1 << ' > '
            @cl1 << "<a href='#{bread_crumbs1[1]}'>#{bread_item.category2.name}</a>"
          end
          unless bread_item.category3.blank?
            @cl1 << ' > '
            @cl1 << "<a href='#{bread_crumbs1[2]}'>#{bread_item.category3.name}</a>"
          end
        end
      end
    end

    @crumbs = []

    routes = Site.current_node.routes.sort_by{|r| r.parent.sort_no}
    routes.each do |r|
      @crumbs << r.parent_tree
    end

    if Site.current_item.class != Cms::Node
      @crumbs = Site.current_item.bread_crumbs(@crumbs, :uri => Site.current_node.public_uri)
    end

    @render_crumbs = lambda do |crumbs|
      h = ''
      crumbs.each do |c|
        h << ''
        c.each_with_index do |c2, i2|
          h << ' &gt; ' if i2 != 0
          if c2.class == Cms::Route
            if Site.current_node.public_uri == c2.node.public_uri
              title_query_string = ''
              title_query_string  = '?title_id=' if params[:title_id].to_s != ''
              title_query_string  = '?title_id=' unless bread_item.blank?
              if bread_item.blank?
                h << '<a href="' + c2.node.public_uri.chop  + title_query_string + params[:title_id].to_s +  '">' + c2.display_title + '</a>'
              else
                h << '<a href="' + c2.node.public_uri.chop  + title_query_string + bread_item.title_id.to_s +  '">' + c2.display_title + '</a>'
              end
            else
              h << '<a href="' + c2.node.public_uri + '">' + c2.display_title + '</a>'
            end
          elsif c2.class == Array
            c2.each_with_index do |c3, i3|
              h << '、' if i3 != 0
              h << '<a href="' + c3[:uri] + '">' + c3[:name] + '</a>'
            end
          else
            h << '<a href="' + c2[:uri] + '">' + c2[:name] + '</a>'
          end
        end
        h << ''
      end
      h
    end
  end
end
