# coding : utf-8

module Sys::Lib::Mail
  
  @@search_contents_depth = 5
  
  def html_mail?
    #TODO: @mail.html_partで判定してはいけない？
    search_html = Proc.new do |p, lv|
      return true if !p.attachment? && p.mime_type == "text/html" 
      p.parts.each { |c| search_html.call(c, lv + 1) } if p.multipart? && lv < @@search_contents_depth
    end
    search_html.call(@mail, 0)
    false
  end
  
  def date(format = '%Y-%m-%d %H:%M', nullif = nil)
    @mail.date.blank? ? nullif : @mail.date.strftime(format)
  end
  
  def from_addr
    extract_address_from_mail_list(friendly_from_addr)
  end
  
  def friendly_from_addr
    field = @mail.header[:from]
    field.value = correct_shift_jis(field.value)
    return field.to_s if field.to_s.encoding.name == 'UTF-8' rescue nil ##
    field.blank? ? 'unknown' : decode(field.value)
  rescue => e
    "#read failed: #{e}"
  end
  
  def friendly_to_addrs
    collect_addrs(@mail.header[:to])
  rescue => e
    ["#read failed: #{e}"]
  end
  
  def simple_to_addr
    addrs = friendly_to_addrs
    "#{addrs.first}#{%Q( 他) if addrs.size > 1}"
  end
  
  def friendly_cc_addrs
    collect_addrs(@mail.header[:cc])
  rescue => e
    ["#read failed: #{e}"]
  end
  
  def friendly_bcc_addrs
    collect_addrs(@mail.header[:bcc])
  rescue => e
    ["#read failed: #{e}"]
  end
  
  def friendly_reply_to_addrs(all_members = nil)
    addrs = collect_addrs(@mail.header[:reply_to])
    addrs = [friendly_from_addr] if addrs.blank?
    if all_members
      addrs += friendly_to_addrs
      addrs = uniq_addrs(addrs)
      addrs.delete_if{|a| a.index(Core.user.email)} if addrs.size > 1
    end
    addrs
  rescue => e
    ["#read failed: #{e}"]
  end
  
  def sender
    field = @mail.header[:sender]
    field.blank? ? friendly_from_addr : decode(field.value)
  rescue => e
    "#read failed: #{e}"
  end
  
  def subject
    field = @mail.header[:subject]
    return 'no subject' if field.blank?
    field.value = correct_shift_jis(field.value)
    field.value = correct_utf7(field.value)
    return decode(field.to_s) if field.to_s.encoding.name == 'UTF-8' rescue nil ##
    field.blank? ? 'no subject' : decode(field.value)
  rescue => e
    "#read failed: #{e}"
  end
  
  def has_disposition_notification_to?
    !@mail.header[:disposition_notification_to].blank?
  end
  
  def disposition_notification_to_addrs
    field = @mail.header[:disposition_notification_to]
    return nil if field.blank?
    value = correct_shift_jis(field.value)
    begin
      field.field = Mail::DispositionNotificationToField.new(value)
      return field.addrs
    rescue => e
      error_log(e)
      return nil
    end  
  end
  
  def text_body
    return @text_body if @text_body

    inlines = inline_contents
    
    inlines.each do |content|
      if !content.attachment? && (content.alternative? || content.content_type == "text/plain" || content.content_type == "text/html") 
        @text_body = content.text_body
        break
      end
    end
    return @text_body
  end
  
  def html_image_was_omited?
    @html_image_was_omited
  end
  
  def html_body(options = {})
    return @html_body if @html_body

    inlines = inline_contents(options)
    inlines.each do |content|
      if !content.attachment? && (content.alternative? || content.content_type == "text/html")
        @html_body = content.html_body
        break
      end
    end
    @html_body
  end 
  
  def html_body_for_edit
    decoded = html_body(:replace_cid => true)
    if decoded =~ /<body(\s+[^>]*)?>(.*)<\/body>/i
      $1
    else
      decoded
    end
  end
  
  def referenced_body(type = :answer)
    body = ""
    if type == :answer
      body << text_body.to_s.gsub(/\r\n/, "\n").gsub(/^/, "> ")
    elsif type == :forward
      body << referenced_body_for_forward(:text)
    end
    body
  end
  
  def referenced_html_body(type = :answer)
    body = ""
    if type == :answer
      body << block_quote(html_body_for_edit.to_s.gsub(/\r\n/, "\n"))
    elsif type == :forward
      body << referenced_body_for_forward(:html)
    end
    body
  end
  
  def has_attachments?
    pattern = /^multipart\/(mixed|related|report)$/
    search_multipart = Proc.new do |p, lv|
      return true if p.mime_type =~ pattern || p.attachment?
      p.parts.each {|c| search_multipart.call(c, lv + 1)} if p.multipart? && lv < @@search_contents_depth - 1
    end
    search_multipart.call(@mail, 0)
    false
  end
  
  def has_images?
    pattern = /^image\/(gif|jpeg|png|bmp)$/
    search_multipart = Proc.new do |p, lv|
      return true if p.mime_type =~ pattern
      p.parts.each {|c| search_multipart.call(c, lv + 1)} if p.multipart? && lv < @@search_contents_depth - 1
    end
    search_multipart.call(@mail, 0)
    false
  end
  
  def attachments
    attachments = []
    
    attached_files = lambda do |part, level|
      if part.attachment? && !part.filename.blank? && part.mime_type != 'application/applefile'
        seqno = attachments.size
        body = part.body.decoded rescue part.body.raw_source
        body = decode_uuencode(body) if part.content_transfer_encoding =~ /uuencode/i
        attachments << Sys::Lib::Mail::Attachment.new({
          :seqno             => seqno,
          :content_type      => part.mime_type,
          :name              => part.filename.strip,
          :body              => body,
          :size              => body.bytesize,
          :transfer_encoding => part.content_transfer_encoding
        })            
      elsif part.multipart?
        part.parts.each { |p| attached_files.call(p, level + 1) } if level < @@search_contents_depth
      end
    end
    
    @mail.parts.each_with_index do |p, i|
      if @mail.mime_type == "multipart/report" && i > 0
        p = extend_report_part(p, i + 1)
      end
    end
    
    attached_files.call(@mail, 0)
     
    attachments
  end
  
  def disposition_notification_mail?
    return true if @mail.mime_type == "multipart/report" &&
      @mail.content_type_parameters &&
      @mail.content_type_parameters['report-type'] == 'disposition-notification'
    return false
  end
  
  #def inline_contents
  #  inlines = []
  #  search_inline = Proc.new do |p, lv|
  #    if p.inline? && p.mime_type =~ /^text\/.+$/
  #      inlines << decode(p.body.decoded) if p.mime_type != "text/plain" || p.attachment?
  #    end
  #    p.parts.each { |c| search_inline.call(c, lv + 1) } if p.multipart? && lv < @@search_contents_depth
  #  end    
  #  @mail.parts.each {|p| search_inline.call(p, 1) } if @mail.multipart? 
  #  inlines
  #end
  
  def inline_contents(options = {})
    return @inline_contents if @inline_contents
    
    inlines = []
    alternates = []
    
    collect_text = Proc.new do |parent|
      text = nil
      parent.parts.each do |p|
        if p.mime_type == "text/plain" && !p.attachment?
          text ||= ''
          text += "\n" unless text.blank? 
          text += decode_text_part(p)
        end
      end
      text
    end

    collect_html = Proc.new do |parent|
      html = nil
      parent.parts.each do |p|
        if p.mime_type == "text/html" && !p.attachment?
          html ||= '' 
          html += "<p style=\"margin:0px; padding:0px;\">#{decode_html_part(p, options)}</p>"
        end
      end
      html
    end

    search_inline = Proc.new do |p, lv|
      if lv == 0 || (p.inline? rescue false) || p.content_disposition.blank?
        case
        when p.mime_type == "text/plain" 
          inlines << Sys::Lib::Mail::Inline.new(
            :seqno => inlines.size,
            :content_type => p.mime_type,
            :text_body => decode_text_part(p),
            :attachment => p.attachment?
          ) if lv == 0 || p.attachment?
        when p.mime_type == "text/html"
          inlines << Sys::Lib::Mail::Inline.new(
            :seqno => inlines.size,
            :content_type => p.mime_type,
            :html_body => decode_html_part(p, options),
            :attachment => p.attachment?
          ) if lv == 0 || p.attachment?
        when p.mime_type =~ /^text\/.+$/
          inlines << Sys::Lib::Mail::Inline.new(
            :seqno => inlines.size,
            :content_type => p.mime_type,
            :text_body => decode_text_part(p),
            :attachment => p.attachment?)
        else
          inlines << Sys::Lib::Mail::Inline.new(
            :seqno => inlines.size,
            :content_type => "text/plain",
            :text_body => decode_text_part(p)
          ) if lv == 0 && !p.multipart? && !p.attachment?
        end        
      end
      if p.multipart? && lv < @@search_contents_depth
        text = collect_text.call(p)
        html = collect_html.call(p)
        alt = nil
        if p.mime_type == "multipart/alternative"
          alt = Sys::Lib::Mail::Inline.new(:seqno => inlines.size, :alternative => true)
          alt.text_body = text unless text.blank?
          alt.html_body = html unless html.blank?
          inlines << alt
          alternates << alt
        else
          unless text.blank?
            if alternates[-1] && alternates[-1].text_body.blank?
              alternates[-1].text_body = text
            else
              inlines << Sys::Lib::Mail::Inline.new(
                :seqno => inlines.size,
                :content_type => "text/plain",
                :text_body => text
              )
            end
          end
          unless html.blank?
            if alternates[-1] && alternates[-1].html_body.blank?
              alternates[-1].html_body = html
            else
              inlines << Sys::Lib::Mail::Inline.new(
                :seqno => inlines.size,
                :content_type => "text/html",
                :html_body => html
              )
            end
          end
        end
        p.parts.each { |c| search_inline.call(c, lv + 1) }
        alternates.pop if p.mime_type == "multipart/alternative"
      end
    end
    
    search_inline.call(@mail, 0)
    
    inlines.each do |inline|
      if !inline.text_body && inline.html_body
        inline.text_body = convert_html_to_text(inline.html_body)
      end
    end
    
    @inline_contents = inlines
  end
  
private
  def decode(str, charset = nil)
    if charset && charset.downcase == 'unicode-1-1-utf-7'
      str = Net::IMAP.decode_utf7(str.gsub(/\+([\w\+\/]+)-/, '&\1-'))
    else
      ::NKF::nkf('-wx --cp932', str).gsub(/\0/, "")
    end
  end
  
  def correct_shift_jis(str)
    str = str.gsub(/(=\?)SHIFT-JIS(\?[BQ]\?.+?\?=)/i, '\1' + 'Shift_JIS' +'\2')
  end
  
  def correct_utf7(str)
    if match = str.match(/(=\?)unicode-1-1-utf-7(\?[BQ]\?)(.+?)(\?=)/i)
      str = Net::IMAP.decode_utf7(match[3].gsub(/\+([\w\+\/]+)-/, '&\1-'))
    end
    str
  end
  
  def collect_addrs(fields)
    return [] unless fields
    fields.value = correct_shift_jis(fields.value)
    addrs = []
    fields.each {|f| addrs << (f.name ? "#{decode(f.name)} <#{f.address}>" : f.address) }
    addrs
  end
  
  def uniq_addrs(addrs)
    new_addrs = {}
    addrs.each do |c|
      addr = c.gsub(/.*<(.*)>.*/, '\\1')
      new_addrs[addr] = c unless new_addrs.key?(addr)
    end
    new_addrs.values
  end
  
  def referenced_body_for_forward(format = :text)
    om = "----------------------- Original Message -----------------------\n"
    om << " From:    #{friendly_from_addr}\n"
    om << " To:      #{friendly_to_addrs.join(', ')}\n"
    om << " Cc:      #{friendly_cc_addrs.join(', ')}\n" if friendly_cc_addrs.size > 0
    om << " Date:    #{date('%Y-%m-%d %H:%M:%S')}\n"
    om << " Subject: #{subject}\n"
    om << "----\n\n"
    ome= "\n--------------------- Original Message Ends --------------------"
    
    if format == :html
      om = Util::String.text_to_html(om)
      ome = Util::String.text_to_html(ome)
      html = html_body_for_edit.to_s.gsub(/\r\n/, "\n")
      "#{om}#{html}#{ome}"
    else
      "#{om}#{text_body.to_s.gsub(/\r\n/, "\n")}#{ome}"
    end
  end

  def decode_text_part(part)
    decode(part.body.decoded, part.charset)
  rescue => e
    "# read failed: #{e}"
  end
  
  def decode_html_part(part, options = {})

    body = decode(part.body.decoded, part.charset)
    body, image_was_omited = secure_html_body(body, options)
    @html_image_was_omited ||= image_was_omited
    
    unless options[:replace_cid] == false
      files = []
      
      search_inline_content = Proc.new do |p, lv|
        if p.mime_type == "multipart/related"
          p.parts.each {|f| files << f if f.header['content-id'] && f.filename }
        elsif p.multipart? && lv < @@search_contents_depth - 1
          p.parts.each { |c| search_inline_content.call(c, lv + 1) }  
        end
      end
      search_inline_content.call(@mail, 0)

      files.each_with_index do |f, idx|
        cid  = f.header['content-id'].value.gsub(/^<(.*)>$/, '\\1')
        
        if options[:embed_image] && (data = Base64.encode64(f.decoded)) && data.size < options[:embed_image_size_limit]
          body = body.gsub(%Q(src="cid:#{cid}"), %Q(src="data:#{f.mime_type};base64,#{data}"))
        else
          body = body.gsub(%Q(src="cid:#{cid}"), %Q(src="?filename=#{CGI::escape(f.filename)}&download=#{idx}"))
        end
      end
    end
    
    body
  rescue => e
    "# read failed: #{e}"
  end
  
  def secure_html_body(html_body, options = {})
    show_image = false
    html_doc = Hpricot(html_body)
    remove_elms = Hpricot::Elements[]
    body_elm = nil
    #style tag to inline style.
    body_elm = html_doc.search('//body').first
    if body_elm
      body_text = body_elm.to_html
      style_text = html_doc.search('//style/').map do |elm|
        if elm.comment?
          st = elm.to_html.gsub(/<!--(.*?)-->/m, '\1')
        else
          st = elm.inner_text
        end
        st.gsub!(/\/\*.*?\*\//m, ' ')
        st.gsub!(/@(import|charset)\s+(url\(.*?\)|["'].*?["'])(\s+.*?)?;/im, ' ')
        st.gsub!(/@(font-face|page)(\s+[^\{]+)?\s*\{[^\}]*\}/im, ' ')
        st
      end.join("\n").strip
      begin
        body_text = TamTam.inline(:css => style_text, :body => body_text)
      rescue InvalidStyleException => e
        error_log(e)
      end      
      html_doc = Hpricot(body_text).search('/body').first
    end
        
    html_doc.search('//').each do |elm|
      if elm.doctype? || elm.comment? || elm.class == Hpricot::CData
        remove_elms << elm
        next        
      end
      next unless elm.elem?
      style = elm['style']
      if style
        elm['style'] = style = style.gsub(/\/\*.*?\*\//m, ' ').gsub(/[\r\n]/, ' ').strip
        if style =~ /[:\s]expression\(/i || style =~ /(^|;)[^:]*?behavior\s*:/i
          elm.remove_attribute('style')
        end
      end
      if style = elm['style']
        style.gsub!(/(\A|\s)((position|top|left|display)\s*:\s*\w+\s*;)/i, '\1')
        elm.set_attribute('style', style)
      end
      elm.attributes.to_hash.each do |k, v|
        elm.remove_attribute(k) if k =~ /^on/i          
      end
      elm.remove_attribute('id') if elm['id']
      elm.remove_attribute('class') if elm['class']
      case elm.pathname
      when 'applet', 'base', 'button', 'bgsound', 'embed', 'form', 'frame', 'frameset', 'head', 'iframe',
        'input', 'isindex', 'link', 'meta', 'object', 'optgroup', 'option', 'param',
        'script', 'select', 'style', 'textarea', 'title'
        remove_elms << elm
        next
      when 'a', 'area'
        elm['target'] = '_blank'
        elm.remove_attribute('href') if elm['href'] && elm['href'].strip =~ /^\w+?script:/i 
      when 'img'
        elm.remove_attribute('src') if elm['src'] && elm['src'].strip =~ /^\w+?script:/i
      end
      unless options[:show_image]
        style = elm['style']
        elm['style'] = style.gsub(/([:\s])url\(.*?\)/i) do |match|
          show_image = true
          "#{$1}url()"
        end if style       
        case elm.pathname
        when 'img'
          if elm['src']
            show_image = true
            elm.remove_attribute('src')
          end
        end
      end
    end
    remove_elms.remove

    [html_doc.inner_html, show_image]
  end

  def block_quote(html)
    %Q(<blockquote style="margin: 2px 0px 2px 5px; padding: 0px 0px 0px 5px; border-left-style: solid; border-left-width: 2px; border-left-color: silver;">#{html}</blockquote>\n)
  end

  def decode_uuencode(body)
    if match = body.gsub("\r\n", "\n").match(/^begin.*?\n([ \t].*?\n)*(.*)\n[ `]+\nend/m) 
      dec = match[2].unpack('u').first
      body = dec unless dec.blank?        
    end   
    body
  end
  
  def extend_report_part(part, number)
    class << part
      def _report_part_sequence_number=(val)
        @_report_part_sequence_number = val
      end
      
      def find_attachment
        _rslt = super
        return _rslt if _rslt 
        return "ReportPart#{@_report_part_sequence_number}.txt" if mime_type =~ /^(text|message)\/.+$/
        nil
      end
    end
    part._report_part_sequence_number = number
    part
  end

  def extend_content_type_field(field)
    class << field
      def encoded
        parameters.delete :charset
        super
      end
    end
    field
  end

  def extend_bcc_field(field)
    class << field
      def encoded
        do_encode(CAPITALIZED_FIELD)
      end
    end
  end
  
  def extend_subject_field(field)
    class << field
      def encoded
        enc = "#{name}: #{value}"
        enc.gsub!(/^(.+)\r?\n\s*$/m, '\1')
        "#{enc}\r\n"
      end
    end
  end

  def extend_header_fields(header_fields)
    #Extend Mail::FieldList
    class << header_fields
      def <<(new_field)
        if new_field.name.downcase == Mail::DispositionNotificationToField::FIELD_NAME
          new_field.field = Mail::DispositionNotificationToField.new(new_field.value, new_field.charset)
        end
        super(new_field)
      end
    end    
  end
  
  def convert_html_to_text(html)
    text = html.gsub(/[\r\n]/, "").gsub(/<br\s*\/?>/, "\n").gsub(/<[^>]*>/, "")
    text = CGI.unescapeHTML(text).gsub(/&nbsp;/, " ")
    text
  end
  
  def extract_address_from_mail_list(from)
    if from.match(/<(.+)>/)
      from = $1
    end
    from
  end
  
  def extract_addresses_from_mail_list(froms)
    froms ||= ""
    froms.split(/,/).map do |from|
      extract_address_from_mail_list(from)
    end
  end
  
end