module Gw::Model::Hcs_checkup_setting

  def self.remind(ucode = Core.user.code, user = Core.user)
    reminders = []
    if self.reminder_enable_user?(user)
      reminders += self.remind_application_expiration(ucode, user)
      reminders += self.remind_application_fixed(ucode, user)
    end
    reminders
  end

  def self.remind_xml(ucode, user, xml_data = nil)
dump ["Gw::Tool::Reminder.checker_api　hcs_checkup_setting_remind_xml", Time.now.strftime('%Y-%m-%d %H:%M:%S'), ucode]
    return xml_data if ucode.blank?
    return xml_data if xml_data.blank?

    items = remind(ucode, user)
    if items.blank?
      return xml_data
    end

    items.each do |item|
      xml_data  << %Q(<entry>)
      xml_data  << %Q(<id>settig#{item[:id]}</id>)
      xml_data  << %Q(<link rel="alternate" href="#{item[:url]}"/>)
      begin
        xml_data  << %Q(<updated>#{item[:date_d].strftime('%Y-%m-%d %H:%M:%S')}</updated>)
      rescue
        xml_data  << %Q(<updated></updated>)
      end
      xml_data  << %Q(<category term="hcsCheckup">各種検診申込</category>)
      xml_data  << %Q(<title>#{item[:xml_title]}</title>)
      xml_data  << %Q(<author><name></name></author>)
      xml_data  << %Q(</entry>)
    end
    return xml_data
  end

protected

  def self.reminder_enable_user?(user)
    if user.groups[0].parent_id != 16
      if user.ldap == 1 || user.code.length == 3 || user.code == 'gwbbs' || user.code == 'admin'
        return true
      end
    end
    return false
  end

  def self.remind_application_expiration(ucode,user = Core.user)
    reminders = []
    return reminders if user.groups.blank?

    confs = Hcs::CheckupConfSetting.enable_reminder_items({:user_group => user.groups[0]})

    fyear = Gw::YearFiscalJp.get_record(Time.now)

    item = Hcs::CheckupMedical.where(
      :conf_id => Hcs::CheckupConfSetting.enable_items(:checkup_kind => 1).map{|x| x.id},
      :checkup_ucode => ucode, 
      :state => ['enabled', 'decided'])
    item = item.where(:checkup_fyear_id => fyear.id) if fyear
    uitem = item.first

    confs.each do |conf|
      model = nil
      case conf.checkup_kind
      when 1 #定期検診
        next if uitem
      when 2 #被扶養配偶者検診
        model = Hcs::CheckupPartnerMedical
      when 3 #特定検診
        model = Hcs::CheckupSpecificMedical
      when 4 #一般検診
        model = Hcs::CheckupGeneralMedical
      end

      if model
        next if model.where(
          :conf_id => conf.id, 
          :checkup_type => conf.checkup_type, 
          :checkup_ucode => ucode, 
          :state => ['enabled', 'decided']).first
      end

      uri = Hcs::CheckupBase.checkup_main_uri(conf.checkup_kind)

      reminders << {
        :id => conf.id,
        :xml_title => conf.message,
        :url => uri,
        :date_str => conf.end_time.strftime("%m/%d %H:%M"),
        :cls => conf.show_reminder_title,
        :title => %Q(<a href="#{uri}">#{conf.message}</a>),
        :date_d => conf.end_time
      }
    end

    reminders
  end


  def self.remind_application_fixed(ucode,user = Core.user)
    reminders = []
    return reminders if user.groups.blank?
    confs = Hcs::CheckupConfSetting.enable_fixed_reminder_items({:user_group => user.groups[0]})

    confs.each do |conf|
      model = nil
      case conf.checkup_kind
      when 1 #定期検診
        model = Hcs::CheckupMedical
      when 2 #被扶養配偶者検診
        model = Hcs::CheckupPartnerMedical
      when 3 #特定検診
        model = Hcs::CheckupSpecificMedical
      when 4 #一般検診
        model = Hcs::CheckupGeneralMedical
      end

      if model
        item = model.where(
          :conf_id => conf.id, 
          :checkup_type => conf.checkup_type, 
          :checkup_ucode => ucode, 
          :state => 'decided').first

        if item
          reminders << {
            :id => conf.id,
            :xml_title => conf.fixed_message,
            :url => item.checkup_show_url,
            :date_str => conf.fixed_start_at.strftime("%m/%d %H:%M"),
            :cls => conf.show_reminder_title,
            :title => %Q(<a href="#{item.checkup_show_url}">#{conf.fixed_message}</a>),
            :date_d => conf.fixed_start_at
          }
        end
      end
    end

    reminders
  end
end
