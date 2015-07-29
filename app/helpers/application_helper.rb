# encoding: utf-8
module ApplicationHelper
  ## nl2br
  def br(str)
    str.gsub(/\r\n|\r|\n/, '<br />').html_safe
  end

  ## nl2br and escape
  def hbr(str)
    str = html_escape(str)
    str.gsub(/\r\n|\r|\n/, '<br />').html_safe
  end

  def ass(alt = nil, &block)
    begin
      yield
    rescue NoMethodError => e
      here = caller.grep(/gw/).first
        alt
    end
  end

  ## wrap long string
  def text_wrap(text, col = 80, char = " ")
    #text.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/, "\\1\\3#{char}")
    #text.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/, "\\1\\2\\3#{char}")
    #text.gsub(/(.{#{col}})( +|$\n?)|(.{#{col}})/, "\\1\\2\\3#{char}")
    text = text.gsub("\r\n", "\n")
    text.gsub(/(.{#{col}})(( *$\n?)| +)|(.{#{col}})/) do |match|
      if $3
        "#{$1}#{$2}"
      else
        "#{$1}#{$2}#{$4}#{char}"
      end
    end
  end

  ## safe calling
  def safe(alt = nil, &block)
    begin
      yield
    rescue NoMethodError => e
      # nil判定を追加
      #if e.respond_to? :args and (e.args.nil? or (!e.args.blank? and e.args.first.nil?))
        alt
      #else
        # 原因がnilクラスへのアクセスでない場合は例外スロー
      #  raise
      #end
    end
  end

  ## paginates
  def paginate(items, options = {})
    return '' unless items
    defaults = {
      :params         => p,
      :previous_label => '前のページ',
      :next_label     => '次のページ',
      :link_separator => '<span class="separator"> | </span' + "\n" + '>'
    }
    if request.mobile? && !request.smart_phone?
      defaults[:page_links]     = false
      defaults[:previous_label] = '&lt;&lt;*前へ'
      defaults[:next_label]     = '次へ#&gt;&gt;'
    end
    links = will_paginate(items, defaults.merge!(options))
    return links if links.blank?
    if Core.request_uri != Core.internal_uri
      links.gsub!(/href="#{URI.encode(Core.internal_uri)}/) do |m|
        m.gsub(/^(href=").*/, '\1' + URI.encode(Core.request_uri))
      end
    end
    if request.mobile? && !request.smart_phone?
      links.gsub!(/<a [^>]*?rel="prev( |")/) {|m| m.gsub(/<a /, '<a accesskey="*" ')}
      links.gsub!(/<a [^>]*?rel="next( |")/) {|m| m.gsub(/<a /, '<a accesskey="#" ')}
    end
    links
  end

###  ## Emoji
###  def emoji(name)
###    require 'jpmobile'
###    return Cms::Lib::Mobile::Emoji.convert(name, request.mobile)
###  end
###
###  ## Furigana
###  def ruby(str, ruby = nil)
###    ruby = Page.ruby unless ruby
###    return ruby == true ? Cms::Lib::Navi::Ruby.convert(str) : str
###  end

  ## Number format
  def number_format(num)
    number_to_currency(num, :unit => '', :precision => 0)
  end

  #show tag if condition is true.
  def show_tag_if(tag, cond, options = {}, &block)
    unless cond
      options[:style] ||= ''
      options[:style] += 'display:none;'
    end

    content_tag(tag, options, &block)
  end

  def div_notice(str=nil)
    str = flash[:notice] || str
    Gw.div_notice(str)
  end

  def show_notice(str="表示する項目はありません。")
    div_notice(str)
  end
  
  def no_item_notice(str="表示する項目はありません。")
    Gw.div_notice(str)
  end

  def hbf_struct(prefix, options={})
    header, body, footer = options[:header], options[:body], options[:footer]
    ret = ''
    ret += %Q(<div class="#{prefix}Header">#{header}</div>) if !header.blank?
    ret += %Q(<div class="#{prefix}Header"><h2 class="#{prefix}Title"></h2></div>) if options[:prop_div] == 'prop'
    ret += %Q(<div class="#{prefix}Body">#{body}</div>)
    ret += %Q(<div class="#{prefix}Footer">#{footer}</div>) if !footer.blank?
    return ret
  end

  def hhbff_struct(ident, action, options={})
    body = hbf_struct(:pieceBody, :header=>options[:body][:header], :body=>options[:body][:body], :footer=>options[:body][:footer])
    ret = piece_struct2(ident, action, :header=>options[:header], :body=>body, :footer=>options[:footer], :prop_div=>options[:prop_div])
    return ret
  end

  def piece_struct(ident, action, header = '', body = '', footer = '')
    ret = %Q(<div class="piece #{ident} #{action}">)
    ret += hbf_struct(:piece, :header=>header, :body=>body, :footer=>footer)
    ret += %Q(</div>)
    return ret
  end

  def piece_struct2(ident, action, options={})
    ret = %Q(<div class="piece #{ident} #{action}">)
    ret += hbf_struct(:piece, :header=>options[:header], :body=>options[:body], :footer=>options[:footer], :prop_div=>options[:prop_div])
    ret += %Q(</div>)
    return ret
  end

  def tabbox_struct(tab_captions, selected_tab_idx=nil, options={})
    tab_current_cls_s = ' ' + Gw.trim(nz(options[:tab_current_cls_s], 'current'))
    id_prefix = Gw.trim(nz(options[:id_prefix], nz(options[:name_prefix], '')))
    id_prefix = "[#{id_prefix}]" if !id_prefix.blank?
    tabs = <<-"EOL"
<div class="tabBox">
<table class="tabtable">
<tbody>
<tr>
<td class="spaceLeft"></td>
EOL
    tab_idx = 0
    tab_captions.each_with_index{|x, idx|
      tab_idx += 1
      _name = "tabBox#{id_prefix}[#{tab_idx}]"
      _id = Gw.idize(_name)
      tabs += %Q(<td class="tab#{selected_tab_idx - 1 == idx ? tab_current_cls_s : nil}" id="#{_id}">#{x}</td>) +
        (tab_captions.length - 1 == idx ? '' : '<td class="spaceCenter"></td>')
    }
    tabs += <<-"EOL"
<td class="spaceRight"></td>
</tr>
</tbody>
</table>
</div><!--tabBox-->
EOL
    return tabs
  end
  def search_struct(search_fields, options={})
    submits = <<-EOL
#{submit_tag '検索',     :name => :search}
#{submit_tag 'リセット', :name => :reset}
EOL
    @content_for_form = ''
    content_for :form do
      form_tag '', :method => :get, :class => 'search' do
        if options[:old].blank?
          concat <<-EOL
<div class="indication">
#{ret=''; search_fields.each{|search_field|
  ret += search_field
}; ret}
#{submits}
</div>
EOL
        else
          concat <<-EOL
<table>
<tr>
#{ret=''; search_fields.each{|search_field|
  ret += "<td>#{search_field}</td>"
}; ret}
<td class="submitters">
#{submits}
</td>
</tr>
</table>
EOL
        end
      end
    end
    @content_for_form
  end

  def required_head
    Gw.required_head
  end
  def required(str='※')
    Gw.required(str)
  end



  def filter_select_tag(value, relation_name, params, options={})
    before  = options[:before]  ? options[:before]  : [['全て', :all]]
    after   = options[:after]   ? options[:after]   : []
    default = options[:default] ? options[:default] : nil
    select_tag( value ,options_for_select( Gw.yaml_to_array_for_select_with_additions(before, relation_name, after), params[value] ? params[value] : default) )
  end

end
