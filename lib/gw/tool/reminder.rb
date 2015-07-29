# encoding: utf-8
class Gw::Tool::Reminder

  def self.checker_api(uid)
    #dump ["Gw::Tool::Reminder.checker_api",Time.now.strftime('%Y-%m-%d %H:%M:%S'),uid]
    xml_data = ""
    xml_data  << %Q(<?xml version="1.0" encoding="UTF-8"?>)
    xml_data  << %Q(<feed xmlns="http://www.w3.org/2005/Atom">)
    xml_data  << %Q(<id>tag:2011:/api/pref/rm</id>)
    xml_data  << %Q(<title>リマインダー</title>)
    xml_data  << %Q(<updated>#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}</updated>)
    xml_data = Gw::Model::Memo.remind_xml(uid,xml_data)
    xml_data = Gw::Model::Monitor.remind_xml(uid,xml_data )
    xml_data = Gw::Model::Circular.remind_xml(uid,xml_data)
    xml_data = Gw::Model::Workflow.remind_xml(uid,xml_data)
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
