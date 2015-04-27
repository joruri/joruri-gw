class Gw::Script::MeetingMonitor < System::Script::Base
  def self.delete_expired
    run do
      log "ログ削除処理" do
        del = Gw::MeetingAccessLog.created_before(3.days.ago).delete_all
        log "#{del} deleted"
      end

      log "テーブル最適化" do
        Gw::MeetingAccessLog.optimize_and_analyze_table
      end
    end
  end

  def self.monitor_notice
    now = Time.now
    dump "#{self}, 会議等案内システム／出退表示システム　死活監視通知 (処理開始)"
    dump "#{self}, 処理実行時間　#{now.strftime('%Y-%m-%d %H:%M')}"
    date_setting = Gw.holiday?(now)
    if date_setting == false
      dump "#{self}, 処理実行日は平日"
      date_type = "平日"
    else
      dump "#{self}, 処理実行日は休日"
      date_type = "休日"
    end
    #管理情報取得
    items = Gw::MeetingMonitorSetting.where('conditions = "enabled" AND deleted_at IS NULL').order('updated_at desc')
    dump "#{self}, 管理情報登録なし　終了." if items.blank?
    return if items.blank?
    now_hour = now.strftime('%H')
    now_minutes = now.strftime('%M')
    if now_hour.to_i <= 8
      if now_minutes.to_i < 30
        dump "#{self}, #{system_name}／監視対象時間外　終了"
        return
      end
    elsif  now_hour.to_i >= 18
      if now_minutes.to_i > 15
        dump "#{self}, #{system_name}／監視対象時間外"
        return
      end
    end
    managers = Gw::MeetingMonitorManager.where("state = ? AND deleted_at IS NULL AND manager_user_addr IS NOT NULL", 'enabled')
    for item in items
      system_type = Gw::MeetingMonitorSetting.system_show(item.monitor_type)
      system_name = "#{system_type}：#{item.name}：#{item.ip_address}"
      dump "#{self}, #{system_name}／死活監視　開始"
      dump "#{self}, #{system_name}／監視状況設定なし" if item.state.blank?
      next if item.state.blank?
      if item.state == "off"
        dump "#{self}, #{system_name}／監視停止中"
        mail_notice = false
        if now_hour.to_i == 8
          if (now_minutes.to_i >= 30 && now_minutes.to_i < 40)
            mail_notice = true
          end
        elsif now_hour.to_i > 8
          mail_notice = true
        end
        if mail_notice == true
          dump "#{self}, #{system_name}／8:30までに監視が開始されていない"
          if self.date_notice(date_setting,item) == false
            dump "#{self}, #{system_name}／#{date_type}は通知を行わない"
            next
          else
            dump "#{self}, #{system_name}／#{date_type}は通知を行う"
          end
          managers.each do |m|
            mail_from  = nz(item.mail_from,AppConfig.gw.meeting_montor_settings[:admin_email_from])
            mail_title = nz(item.mail_title,"#{system_type}　監視機能")
            mail_body  = nz(item.notice_body,"#{system_name}の監視が、8:30になっても開始されていません。")
            Gw.send_mail(mail_from, m.manager_user_addr, mail_title, mail_body)
            dump "#{self}, #{system_name}／8:30までに監視が開始されていないためメール通知を実行　#{m.manager_user_addr}"
          end
          next
        end
      else
        if self.date_notice(date_setting,item) == false
          dump "#{self}, #{system_name}／#{date_type}は通知を行わない"
          next
        else
          dump "#{self}, #{system_name}／#{date_type}は通知を行う"
        end
        log = Gw::MeetingAccessLog.where("ip_address = ?",item.ip_address).order('created_at desc').first
        dump "#{self}, #{system_name}／監視対象ログなし" if log.blank?
        next if log.blank?
        last_access = log.created_at
        dump "#{self}, #{system_name}／最終アクセス時間　#{last_access.strftime('%Y-%m-%d %H:%M')}"
        gap = sprintf("%d",(now - last_access)/ 60)
        if gap.to_i > 30
          dump "#{self}, 通知対象なし　終了." if managers.blank?
          next if managers.blank?
          managers.each do |m|
            mail_from  = nz(item.mail_from,AppConfig.gw.meeting_montor_settings[:admin_email_from])
            mail_title = nz(item.mail_title,"#{system_type}　監視機能")
            mail_body  = nz(item.mail_body,"#{system_name}から、30分以上アクセスがありませんでした。\nシステムが稼動しているかチェックしてください。")
            Gw.send_mail(mail_from, m.manager_user_addr, mail_title, mail_body)
            dump "#{self}, #{system_name}／最終アクセスが30分以上前のためメール通知を実行　#{m.manager_user_addr}"
          end
        else
          dump "#{self}, #{system_name}／最終アクセスが30分以内のため通知を実行せず"
        end
      end
      dump "#{self}, #{system_name}／死活監視　終了"
    end
    dump "#{self}, 会議等案内システム／出退表示システム　死活監視通知 (処理終了)"
  end

  #通知設定
  def self.date_notice(is_holiday,item)
    ret = false
    if is_holiday == false
      if item.weekday_notice == "off"
        ret = false
      else
        ret = true
      end
    else
      if item.holiday_notice == "off"
        ret = false
      else
        ret = true
      end
    end
    return ret
  end
end