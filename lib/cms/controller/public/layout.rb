module Cms::Controller::Public::Layout
  def self.included(mod)
    mod.after_filter :render_public_layout
  end

  def render_public_layout
    return if JoruriContext[:hoge]
    JoruriContext[:hoge] = true
    Site.current_item = Site.current_node unless Site.current_item

    return true if @performed_redirect
    return true if @skip_layout
    return true if params[:format] && params[:format] != 'html'
    return true if Page.error

    content_data = response.body

    erase_render_results
    reset_variables_added_to_assigns
    @template.instance_variable_set("@content_for_layout", '')

    if Site.mobile
      Site.current_item = Site.find_mobile_node
    end

    pp "Site.current_item" if false
    pp Site.current_item if false
    layout_id = defined?(Site.current_item.layout_id) ? Site.current_item.layout_id : nil
    Site.current_node.parent_tree.each do |r|
      layout_id = r.layout_id if r.layout_id
    end unless layout_id

    unless layout_id
      return render(:text => content_data)
    end

    Page.layout = Cms::Layout.find(layout_id)

    if request.mobile?
      if request.mobile.smartphone?
        if Page.layout.s_mobile_body.blank?
          layout_data = Page.layout.mobile_body
        else
          layout_data = Page.layout.s_mobile_body
        end
      else
        layout_data = Page.layout.mobile_body
      end
    else
      layout_data = Page.layout.body
    end
    layout_data = Page.layout.body if layout_data.blank?

    layout_data = replace_piece(layout_data)

    content_data = public_show_path("#{params['controller']}/#{params['action']}") + content_data if PUBLIC_SHOW_PATH == 1
    content_data = replace_piece(content_data) if ENABLE_PIECE_IN_CONTENT == 1
    content_data = replace_directive(content_data) if ENABLE_DIRECTIVE_IN_CONTENT == 1
    layout_data = layout_data.gsub("[[content]]") { content_data }

    names = []
    layout_data.scan(/\[\[text\/([0-9a-zA-Z_-]+)\]\]/) {|name| names << name}

    names.uniq.each do |name|
      text = Cms::Text.new.public
      text.name = name
      if current_text = text.find(:first)
        text_data = current_text.body
        layout_data = layout_data.gsub("[[text/#{name}]]") { text_data }
      else
        layout_data = layout_data.gsub("[[text/#{name}]]", '')
      end
    end

    if request.mobile?
      unless request.mobile.smartphone?
        begin
          require 'tamtam'
          layout_data = TamTam.inline(
            :css  => Page.layout.tamtam_css,
            :body => layout_data
          )
        rescue InvalidStyleException
          dump "TamTamError: #{request.env['REQUEST_URI']}"
        end
        case request.mobile
        when Jpmobile::Mobile::Docomo
          headers["Content-Type"] = "application/xhtml+xml; charset=utf-8"
        when Jpmobile::Mobile::Au
        when Jpmobile::Mobile::Softbank
        when Jpmobile::Mobile::Willcom
        else
        end
      end
    end

    if request.env['PATH_INFO'].to_s =~ /\.html\.r$/
      layout_data = Util::Html::Ruby.convert(layout_data)
    end

    if Site.mode == 'publish'
      page_data = render_to_string :text => layout_data, :layout => 'layouts/public'
      response = {
        :page_type    => 'text/html',
        :page_size    => page_data.size,
        :page_data    => page_data,
        :content_data => content_data,
      }
      render :xml => response.to_xml(:root => 'data', :dasherize => false, :indent => 0);
    else
      render :text => layout_data, :layout => 'layouts/public'
    end
  end
private
  def public_show_path(message)
    PUBLIC_SHOW_PATH == 1 ? %Q(<div class="notice">Find me in /app/views/#{message}.html.erb(automatically rendered by layout.rb)</div>) : ''
  end
end
