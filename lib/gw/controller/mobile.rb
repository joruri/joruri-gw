# encoding: utf-8
module Gw::Controller::Mobile
  def self.convert_for_mobile_body(body,session_id)
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
    if @file_link==true
      body += %Q(<br /><span style="color: #ff0000;">※パケット定額サービスに入っていない場合、高額の通信料が発生する場合があります。</span>)
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
    return true if uri =~ /_attach/i
    return true if uri =~ /download_object/i
    if uri =~ /^\/$|gw\/memos|\/schedules|gw\/schedule_todos|gwbbs\/docs|gw\/todos|login|mobile|portal/
      return false if uri =~ /month/
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
    mobile_uri = Gw::UserProperty.find(:first,
      :conditions=>["class_id = ? AND name = ? ",3,"mobile_mail"])
    return "-1" if mobile_uri.blank?

    mobile_use_ssl = Gw::UserProperty.find(:first,
      :conditions=>["class_id = ? AND name = ? and options = ?",3,"mobile_ssl","true"])
    if mobile_use_ssl.blank?
      sso_use_ssl = false
    else
      sso_use_ssl = true
    end

    require 'net/http'
    if sso_use_ssl == true
      http = Net::HTTP.new(mobile_uri.options, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    else
      http = Net::HTTP.new(mobile_uri.options, 80)
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
  end

  def self.sche_category_show(cate)
    return nil if cate.blank?
    categories = [
      ["category100", "【会議】"],
      ["category2", "【講習会】"],
      ["category200", "【出張】"],
      ["category300", "【研修】"],
      ["category400", "【休暇】"],
      ["category5", "【往訪】"],
      ["category6", "【来訪】"],
      ["category500", "【仕事集中タイム】"],
      ["category600", "【来客対応】"],
      ["category700", "【重要イベント】"],
      ["category800", "【期限日】"],
      ["category900", "【注意】"],
      ["category950", "【県議会関係】"],
      ["category1000", "【予定あり】"],
      ["category1100", "【その他１】"],
      ["category1200", "【その他２】"]
    ]
    categories.each {|c| return c[1] if c[0] == cate}
    return nil
  end
end