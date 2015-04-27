module Gw::Model::Dcn_approval

  def self.remind(uid = Core.user.id)
    items = Gw::DcnApproval.where(:state => 1, :uid => uid).order(:ed_at).all

    items.map{|item|
      {
        :date_str => item.ed_at.nil? ? '' : item.ed_at.strftime("%m/%d %H:%M"),
        :cls => '電子決裁',
        :title => item.body,
        :date_d => item.ed_at
      }
    }
  end

  def self.remind_xml(uid, xml_data = nil)
dump ["Gw::Tool::Reminder.checker_api　dcn_approvals_remind_xml",Time.now.strftime('%Y-%m-%d %H:%M:%S'),uid]
    return xml_data if uid.blank?
    return xml_data if xml_data.blank?

    items = Gw::DcnApproval.where(:state => 1, :uid => uid).order(:ed_at).all
    return xml_data if items.blank?

    items.each do |dcn|
      if dcn.body =~ %r{<a href="(.+?)"}
        href_uri = $1
      else
        href_uri = ""
      end
      xml_data << %Q(<entry>)
      xml_data << %Q(<id>#{dcn.id}</id>)
      xml_data << %Q(<link rel="alternate" href="#{href_uri}"/>)
      xml_data << %Q(<updated>#{dcn.ed_at.strftime('%Y-%m-%d %H:%M:%S')}</updated>)
      xml_data << %Q(<category term="denshiKessai">電子決済</category>)
      xml_data << %Q(<title>#{dcn.title}</title>)
      xml_data << %Q(<author><name>#{dcn.author}</name></author>)
      xml_data << %Q(</entry>)
    end
    xml_data
  end
end
