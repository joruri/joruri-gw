module Gw::Model::ReminderExternal

  def self.remind(ucode = Core.user.code)
    systems = Gw::ReminderExternalSystem.order(:id).all
    systems = systems.index_by(&:code)

    item = Gw::ReminderExternal.new
    item.and :member, ucode
    item.and :deleted_at, 'IS', nil
    items = item.find(:all)

    reminders = []
    items.each do |item|
      name = user_field = pass_field = ""
      if s = systems[item['system']]
        name = s.name
        user_field = s.sso_user_field
        pass_field = s.sso_pass_field
      end
      reminders << {
        :date_str => item.updated.strftime("%m/%d %H:%M"),
        :c => item.system,
        :cls => name,
        :title => %Q(<a href="/_admin/gw/link_sso/redirect_to_external?url=#{item.link}&user_field=#{user_field}&pass_field=#{pass_field}" target="_blank">#{item.title}</a>),
        :date_d => item.updated
      }
    end
    reminders
  end


  def self.remind_xml(ucode , xml_data = nil)
dump ["Gw::Tool::Reminder.checker_api　reminder_externals_remind_xml", Time.now.strftime('%Y-%m-%d %H:%M:%S'), ucode]
    return xml_data if ucode.blank?
    return xml_data if xml_data.blank?
    # 表示対象の最大件数
#    get_max = 3

    systems = Gw::ReminderExternalSystem.order(:id).all
    systems = systems.index_by(&:code)

    item = Gw::ReminderExternal.new
    item.and :member, ucode
    item.and :deleted_at, 'IS', nil
    items = item.find(:all)

    if items.blank?
#      dump ['dcn_approvals_xml' ,'blank',xml_data]
      return xml_data
    end

    items.each do |item|
      if s = systems[item['system']]
        name = s.name
        user_field = s.sso_user_field
        pass_field = s.sso_pass_field
      end
      href_uri = %Q(/_admin/gw/link_sso/redirect_to_external?url=#{item.link}&amp;user_field=#{user_field}&amp;pass_field=#{pass_field})
      xml_data  << %Q(<entry>)
      xml_data  << %Q(<id>ext#{item.id}</id>)
      xml_data  << %Q(<link rel="alternate" href="#{href_uri}"/>)
      xml_data  << %Q(<updated>#{item.updated.strftime('%Y-%m-%d %H:%M:%S')}</updated>)
      xml_data  << %Q(<category term="reminderExternal">旅費システム</category>)
      xml_data  << %Q(<title>#{item.title}</title>)
      xml_data  << %Q(<author><name></name></author>)
      xml_data  << %Q(</entry>)
    end
#    dump ['dcn_approvals_xml' ,xml_data]
    return xml_data
  end
end
