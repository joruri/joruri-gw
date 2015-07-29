# encoding: utf-8
module Gw::Model::Monitor

  def self.remind(uid = Site.user.id)
    item = Gw::MonitorReminder.new
    remind_cond = ["(state=1 AND g_code=?) OR (state=1 AND u_code=?)", Site.user_group.code, Site.user.code]
    items = item.find(:all, :conditions=>remind_cond ,  :order => 'ed_at')
    return items.collect{|x|
      delay_s = ''
      {
      :date_str => x.ed_at.nil? ? '' : x.ed_at.strftime("%m/%d %H:%M"),
      :cls => '照会回答',
      :title => x.title,
      :date_d => x.ed_at
      }
    }
  end

  def self.remind_xml(uid  , xml_data = nil)
    #dump ["Gw::Tool::Reminder.checker_api　monitor_remind_xml",Time.now.strftime('%Y-%m-%d %H:%M:%S'),uid]
    return xml_data if uid.blank?
    return xml_data if xml_data.blank?
    u_cond  = "user_id=#{uid} and end_at is null "
    u_order = "job_order , start_at DESC"
    user  = System::UsersGroup.find(:first , :conditions=>u_cond , :order=>u_order)
    return xml_data if user.blank?
    g_code  = user.group_code

    usertbl = System::User.find_by_id(uid)
    return xml_data if usertbl.blank?
    user_code = usertbl.code

    item = Gw::MonitorReminder.new
    remind_cond = ["(state=1 AND g_code=?) OR (state=1 AND u_code=?)", g_code, user_code]
    items = item.find(:all, :conditions=>remind_cond ,  :order => 'ed_at')
    if items.blank?
      return xml_data
    end
    items.each do |monitor|
      title = monitor.title
      title = title.sub('<a href="/gwmonitor">','')
      title = title.sub('</a>','')
      xml_data  << %Q(<entry>)
      xml_data  << %Q(<id>#{monitor.id}</id>)
      xml_data  << %Q(<link rel="alternate" href="/gwmonitor"/>)
      xml_data  << %Q(<updated>#{monitor.ed_at.strftime('%Y-%m-%d %H:%M:%S')}</updated>)
      xml_data  << %Q(<category term="monitor">照会回答</category>)
      xml_data  << %Q(<title>#{title}</title>)
      xml_data  << %Q(<author><name></name></author>)
      xml_data  << %Q(</entry>)
    end
    #dump ['monitor_xml' ,xml_data]
    return xml_data
  end

end
