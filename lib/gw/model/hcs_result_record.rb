module Gw::Model::Hcs_result_record

  def self.remind(ucode = Core.user.code)
    response = get_reminder(Core.user.code, Core.user.password)

    reminders = JSON.parse(response) rescue []
    reminders.each do |reminder|
      reminder.symbolize_keys!
      reminder[:title].gsub!(/<a href="([^>]+)">/) {|match| %Q(<a href="_admin/gw/link_sso/redirect_to_joruri?to=hcs&path=#{CGI.escape($1)}">)}
      reminder[:date_d] = Time.parse(reminder[:date_d])
    end
    reminders
  end

  def self.remind_xml(ucode, upass, xml_data = nil)
dump ["Gw::Tool::Reminder.checker_api　Hcs_result_record_remind_xml",Time.now.strftime('%Y-%m-%d %H:%M:%S'),ucode]
    return xml_data if ucode.blank?
    return xml_data if xml_data.blank?

    response = get_reminder(ucode, upass)

    reminders = JSON.parse(response) rescue []
    if reminders.blank?
      return xml_data
    else
      reminders.each do |reminder|
        reminder.symbolize_keys!
        reminder[:title].gsub!(/<a href="([^>]+)">/) {|match| %Q(<a href="_admin/gw/link_sso/redirect_to_joruri?to=hcs&amp;path=#{CGI.escape($1)}">)}
        reminder[:date_d] = Time.parse(reminder[:date_d])
        href_uri   = reminder[:title].gsub(/<a .*?href="(.*?)".*?>.*?<\/a>/iom, '\1')
        herf_title = reminder[:title].sub(/(<a .*?href=".*?".*?>)(.*?)(<\/a>)/i, '\2')
        xml_data  << %Q(<entry>)
        xml_data  << %Q(<id>result#{reminder[:date_d].to_i}</id>)
        xml_data  << %Q(<link rel="alternate" href="#{href_uri}"/>)
        xml_data  << %Q(<updated>#{reminder[:date_d].strftime('%Y-%m-%d %H:%M:%S')}</updated>)
        xml_data  << %Q(<category term="hcsCheckup">検診結果</category>)
        xml_data  << %Q(<title>#{herf_title}</title>)
        xml_data  << %Q(<author><name></name></author>)
        xml_data  << %Q(</entry>)
      end
    end

    return xml_data
  end

private

  def self.get_reminder(ucode, upass)
    item = System::Product.where(:product_type => 'hcs').first
    return {} unless item

    uri = item.sso_uri
    return {} unless uri

    require 'net/http'
    Net::HTTP.version_1_2
    http = Net::HTTP.new(uri.host, uri.port, Core.proxy_uri.try(:host), Core.proxy_uri.try(:port))
    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    response = {}
    begin
      timeout(10) do
        http.start do |agent|
          parameters = {}
          parameters[:account]  = ucode
          parameters[:password] = upass
          response = agent.post("/hcs/api/reminders/unseen_results", parameters.to_param).body
        end
      end
    rescue
      return {}
    rescue Timeout::Error
      return {}
    end
    response
  end
end
