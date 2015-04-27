module Gw::Model::Hcs_notification_base_deduction
  def self.remind(uid = nil)
    today = Date.today
    letter = nil

    setting = Hcs::NotificationUserSetting.find_by_user_code(Core.user.code) ||
      Hcs::NotificationUserSetting.new(:seen_reminder_option => 0, :unseen_reminder_option => 5)

    # 診療所控除通知
    model = Hcs::NotificationDeduction.new
    cond = "u_code = '#{Core.user.code}' and deleted_at is NULL"
    item = model.find(:first, :order => 'updated_at DESC',
      :conditions => cond)

    unless item.blank?
      if item.seen == 1
        if setting.seen_reminder_option == 0
          return []
        else
          day_ago = today - (setting.seen_reminder_option - 1).days
        end
      else
        if setting.unseen_reminder_option == 0
          return []
        else
          day_ago = today - (setting.unseen_reminder_option - 1).days
        end
      end
      letter = Hcs::NotificationLetterDeduction.new
      cond_letter = "hcs_notification_letters.parent_id = #{item.parent_id} and u_code = '#{Core.user.code}'" +
        " and '#{day_ago.strftime("%Y-%m-%d")} 00:00:00' <= hcs_notification_letter_deductions.updated_at and hcs_notification_letter_deductions.updated_at <= '#{today.strftime("%Y-%m-%d")} 23:59:59'" +
        " and hcs_notification_letter_deductions.deleted_at is NULL"
      letter = letter.find(:first, :order => 'updated_at DESC',
        :conditions => cond_letter, :joins => :letter)
    end

    if letter.blank?
      ret = Array.new
    else
      ret = [{
        :date_str => letter.updated_at.nil? ? '期限なし' : letter.updated_at.strftime("%m/%d %H:%M"),
        :cls => '共済',
        :title => %Q(<a href="/_admin/gw/link_sso/redirect_to_joruri?to=hcs&path=/hcs/notification/base_deductions/#{item.id}" target="hcs">診療所給与控除通知書の#{letter.data_date.strftime("%Y年%m月")}分が届いています。</a>),
        :date_d => letter.updated_at
      }]
    end
    return ret
  end

  def self.remind_xml(ucode , xml_data = nil)
dump ["Gw::Tool::Reminder.checker_api　Hcs_notification_base_deduction_remind_xml",Time.now.strftime('%Y-%m-%d %H:%M:%S'),ucode]
    return xml_data if ucode.blank?
    return xml_data if xml_data.blank?
    # 表示対象の最大件数
#    get_max = 3
    today = Date.today
    letter = nil
    setting = Hcs::NotificationUserSetting.find_by_user_code(ucode) ||
      Hcs::NotificationUserSetting.new(:seen_reminder_option => 0, :unseen_reminder_option => 5)

    # 診療所控除通知
    model = Hcs::NotificationDeduction.new
    cond = "u_code = '#{ucode}' and deleted_at is NULL"
    item = model.find(:first, :order => 'updated_at DESC',
      :conditions => cond)

    unless item.blank?
      if item.seen == 1
        if setting.seen_reminder_option == 0
          return xml_data
        else
          day_ago = today - (setting.seen_reminder_option - 1).days
        end
      else
        if setting.unseen_reminder_option == 0
          return xml_data
        else
          day_ago = today - (setting.unseen_reminder_option - 1).days
        end
      end
      letter = Hcs::NotificationLetterDeduction.new
      cond_letter = "hcs_notification_letters.parent_id = #{item.parent_id} and u_code = '#{ucode}'" +
        " and '#{day_ago.strftime("%Y-%m-%d")} 00:00:00' <= hcs_notification_letter_deductions.updated_at and hcs_notification_letter_deductions.updated_at <= '#{today.strftime("%Y-%m-%d")} 23:59:59'" +
        " and hcs_notification_letter_deductions.deleted_at is NULL"
      letter = letter.find(:first, :order => 'updated_at DESC',
        :conditions => cond_letter, :joins => :letter)
    end
    return xml_data if letter.blank?

    href_uri = %Q(/_admin/gw/link_sso/redirect_to_joruri?to=hcs&amp;path=/hcs/notification/base_deductions/#{item.id})
    xml_data  << %Q(<entry>)
    xml_data  << %Q(<id>deduction#{letter.id}</id>)
    xml_data  << %Q(<link rel="alternate" href="#{href_uri}"/>)
    if letter.updated_at.blank?
      xml_data  << %Q(<updated>期限なし</updated>)
    else
      xml_data  << %Q(<updated>#{letter.updated_at.strftime('%Y-%m-%d %H:%M:%S')}</updated>)
    end
    xml_data  << %Q(<category term="notification">共済・互助会通知システム　（控除）</category>)
    xml_data  << %Q(<title>診療所給与控除通知書の#{letter.data_date.strftime("%Y年%m月")}分が届いています。</title>)
    xml_data  << %Q(<author><name>　</name></author>)
    xml_data  << %Q(</entry>)

    return xml_data

  end


end
