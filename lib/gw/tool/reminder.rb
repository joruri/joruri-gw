class Gw::Tool::Reminder

  def self.checker_api(uid, ucode, upass, user)
    #dump ["Gw::Tool::Reminder.checker_api",Time.now.strftime('%Y-%m-%d %H:%M:%S'),uid]
    xml_data = ""
    xml_data  << %Q(<?xml version="1.0" encoding="UTF-8"?>)
    xml_data  << %Q(<feed xmlns="http://www.w3.org/2005/Atom">)
    xml_data  << %Q(<id>tag:2011:/api/pref/rm</id>)
    xml_data  << %Q(<title>リマインダー</title>)
    xml_data  << %Q(<updated>#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}</updated>)


    xml_data = Gw::Model::Memo.remind_xml(user,xml_data)
    xml_data = Gw::Model::Monitor.remind_xml(uid,xml_data)
    xml_data = Gw::Model::Circular.remind_xml(uid,xml_data)
    xml_data = Gw::Model::Workflow.remind_xml(uid,xml_data)

    xml_data = Gw::Model::Plus_update.remind_xml(user, xml_data)
    xml_data = Gw::Model::ReminderExternal.remind_xml(ucode,xml_data)
    xml_data = Gw::Model::Dcn_approval.remind_xml(uid,xml_data)

    use_hcs = Joruri.config.application['reminder.use_hcs'] || false

    if use_hcs == true
      xml_data = Gw::Model::Hcs_notification_base_deduction.remind_xml(ucode, xml_data)
      xml_data = Gw::Model::Hcs_notification_base_benefit.remind_xml(ucode, xml_data)
      xml_data = Gw::Model::Hcs_checkup_setting.remind_xml(ucode,user, xml_data)
      xml_data = Gw::Model::Hcs_result_record.remind_xml(ucode,upass, xml_data)
    end
    xml_data  << %Q(</feed>)
    #dump ["Gw::Tool::Reminder.checker_api",Time.now.strftime('%Y-%m-%d %H:%M:%S'),'return']
    return xml_data
  end

  def self.checker_api_error
    xml_data = ""
    xml_data  << %Q(<?xml version="1.0" encoding="UTF-8"?>)
    xml_data  << %Q(<feed xmlns="http://www.w3.org/2005/Atom">)
    xml_data  << %Q(<id>tag:2011:/api/pref/rm</id>)
    xml_data  << %Q(<title>リマインダー</title>)
    xml_data  << %Q(<updated>#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}</updated>)
    xml_data  << %Q(</feed>)
    return xml_data
  end

end
