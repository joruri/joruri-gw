module Gw::Controller::Mobile
  def self.convert_for_mobile_body(body, session_id, request)
    @file_link = false

    body.gsub!(/<table[ ].*?>.*?<\/table>/iom) do |m|
      '' #remove
    end

    body.gsub!(/[\(]?(([0-9]{2}[-\(\)]+[0-9]{4})|([0-9]{3}[-\(\)]+[0-9]{3,4})|([0-9]{4}[-\(\)]+[0-9]{2}))[-\)]+[0-9]{4}/) do |m|
      "<a href='tel:#{m.gsub(/\D/, '\1')}'>#{m}</a>"
    end

    body.gsub!(/<img .*?src=".*?".*?>/iom) do |m|
      '' #remove
    end

    body = body.gsub(/'/,'"')
    body.gsub!(/<a .*?href=".*?".*?>.*?<\/a>/iom) do |m|
      uri   = m.gsub(/<a .*?href="(.*?)".*?>.*?<\/a>/iom, '\1')
      label = m.sub(/(<a .*?href=".*?".*?>)(.*?)(<\/a>)/i, '\2')
      a_class = m.gsub(/<a .*?class="(.*?)".*?>.*?<\/a>/iom, '\1')
      converted_link = self.convert_link(uri,label,session_id,{:class=>a_class})
      converted_link
    end
    body.gsub!(/<a .*?href=.*? .*?>.*?<\/a>/iom) do |m|
      if m =~ /<a .*?href=".*?".*?>.*?<\/a>/iom
        m
      else
        uri   = m.gsub(/<a .*?href=(.*?) .*?>.*?<\/a>/iom, '\1')
        label = m.sub(/(<a .*?href=.*?.*?>)(.*?)(<\/a>)/i, '\2')
        a_class = m.gsub(/<a .*?class="(.*?)".*?>.*?<\/a>/iom, '\1')
        converted_link = self.convert_link(uri,label,session_id,{:class=>a_class})
        converted_link
      end
    end

    if @file_link
      #添付ファイルダウンロード可否を判定
      downloadable_ips = Joruri.config.application['air_watch.downloadable_ips']
      downloadable = if downloadable_ips.nil?
          true
        else
          remote_ip = request.env[Joruri.config.application['air_watch.remote_ip_key']].to_s.split(',').last.strip
          downloadable_ips.include?(remote_ip)
        end

      if downloadable
        body += %Q(<br /><span style="color: #ff0000;">#{Joruri.config.application['air_watch.download_allow_message']}</span>)
      else
        #添付ファイルダウンロード不可であればリンク削除
        body.gsub!(/<a .*?href="(.*?)".*?>(.*?)<\/a>/iom) do |m|
          text = $2
          if $1 =~ %r(^(/_admin/attaches/|/_admin/_attaches/|/_attaches/))
            text
          else
            m
          end
        end
        body += %Q(<br /><span style="color: #ff0000;">#{Joruri.config.application['air_watch.download_deny_message']}</span>)
      end
    end

    return body
  end

  def self.convert_link(uri,label,session_id,options={})
    @file_link = true if uri =~ /\.(pdf|doc|docx|xls|xlsx|jtd|jst|jpg|gif)$/i
    @file_link = true if uri =~ /_attach/i
    @file_link = true if uri =~ /download_object/i
    class_str =""
    class_str =%Q( class="#{options[:class]}") if !options[:class].blank?

    if uri =~ /^\/$|^(\/|\.\/|\.\.\/)/

      result = self.link_check(uri)
      if result == true

        unless session_id.blank?
          if uri =~ /\?/
            uri += "&_session_id=#{session_id}"
          else
            uri += "?_session_id=#{session_id}"
          end
        end
        converted_link = %Q(<a#{class_str} href="#{uri}">#{label}</a>)
      else
        converted_link = label
      end
    elsif uri =~ /http:\/\/localhost\//

      uri = uri.sub(/http:\/\/localhost\//,"/")
      uri = uri.sub(/limit=100|limit=30|limit=20|limit=40|limit=50/,"limit=10")
      result = self.link_check(uri)
      if result == true

        unless session_id.blank?
          if uri =~ /\?/
            uri += "&_session_id=#{session_id}"
          else
            uri += "?_session_id=#{session_id}"
          end
        end
        converted_link = %Q(<a#{class_str} href="#{uri}">#{label}</a>)
      else
        converted_link = label
      end
    else
      converted_link = %Q(<a#{class_str} href="#{uri}">#{label}</a>)
    end
    return converted_link
  end

  def self.link_check(uri)
    return true if uri =~ /\.(pdf|doc|docx|xls|xlsx|jtd|jst|jpg|gif)$/i
    return true if uri =~ /_admin\/attaches/i
    return true if uri =~ /download_object/i
    return true if uri =~ /portal/i
    if uri =~ /^\/$|gw\/memos|\/schedules|gw\/schedule_todos|gwbbs\/docs|login|gw\/mobile_schedule|gw\/mobile_participants|gwcircular|gw\/simple_schedules/
      return false if uri =~ /month/
      return false unless uri =~ /title_id=1|title_id=36|title_id=48/ if uri =~ /^gwbbs\/docs/
      return true
    else
      return false
    end
  end

  def self.get_board_system_items(genre,title_id)
    ret = Gw::Tool::Board.readable_board?(genre,title_id)
    return ret
  end

  def self.get_recent_mail(uid,pass,mobile_pass)
    para = CGI.escape(pass)
    mobile_para = CGI.escape(mobile_pass)

    get_uri = "/_api/gw/webmail/unseen.xml?account=#{uid}&password=#{para}&mobile_password=#{mobile_para}"
    mobile_uri = System::Product.where(product_type: 'mail').first.try(:sso_uri_mobile)
    return "-1" if mobile_uri.blank?

    require 'net/http'
    http = Net::HTTP.new(mobile_uri.host, mobile_uri.port, Core.proxy_uri.try(:host), Core.proxy_uri.try(:port))
    if mobile_uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    req = Net::HTTP::Get.new(get_uri)

    res = http.request(req)
    res_xml = res.body
    unseen  = res_xml.scan(/<unseen>(.*?)<\/unseen>/)

    if unseen.blank?
      return "-1"
    else
      return unseen[0][0]
    end

  rescue Timeout::Error, Errno::ECONNREFUSED => e
    error_log e
    return "-1"
  end
end