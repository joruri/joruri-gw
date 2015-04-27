module Gw::Model::Memo

  def self.remind(user = Core.user)
    property = Gw::Property::MemoReminder.where(uid: user.id).first_or_new
    return {} if property.memos['read_memos_display'].to_i == 0 && property.memos['unread_memos_display'].to_i == 0

    items = Gw::Memo.memos_for_reminder(Core.user, property).order(:created_at)
    items.map do |item|
      {
        :date_str => item.created_at ? item.created_at.strftime("%m/%d %H:%M") : '期限なし',
        :cls => '連絡メモ',
        :title => %(<a href="/gw/memos/#{item.id}">#{item.title_and_sender}</a>),
        :date_d => item.created_at
      }
    end
  end

  def self.remind_xml(user, xml_data)
    #dump ["Gw::Tool::Reminder.checker_api　memos_remind_xml",Time.now.strftime('%Y-%m-%d %H:%M:%S'),user.id]
    return xml_data if user.blank?
    return xml_data if xml_data.blank?

    property = Gw::Property::MemoReminder.where(uid: user.id).first_or_new
    return xml_data if property.memos['read_memos_display'].to_i == 0 && property.memos['unread_memos_display'].to_i == 0

    items = Gw::Memo.memos_for_reminder(user, property).order(:created_at)
    return xml_data if items.blank?

    items.each do |item|
      xml_data  << %Q(<entry>)
      xml_data  << %Q(<id>#{item.id}</id>)
      xml_data  << %Q(<link rel="alternate" href="/gw/memos/#{item.id}"/>)
      xml_data  << %Q(<updated>#{item.created_at.strftime('%Y-%m-%d %H:%M:%S')}</updated>)
      xml_data  << %Q(<category term="memo">連絡メモ</category>)
      xml_data  << %Q(<title>#{item.title}</title>)
      xml_data  << %Q(<author><name>#{item.uname} (#{item.ucode})</name></author>)
      xml_data  << %Q(</entry>)
    end
    return xml_data
  end
end
