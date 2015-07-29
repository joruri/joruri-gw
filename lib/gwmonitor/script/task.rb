# -*- encoding: utf-8 -*-
class Gwmonitor::Script::Task

  def self.renew_reminder
    Gw::MonitorReminder.update_all("state=0,title=''")
    renew_reminder_section
    renew_reminder_personal
  end

  def self.renew_reminder_section
    dump "#{self}, 回答システム所属用リマインダ更新開始"
    sql = "SELECT `section_code`, COUNT(id) as rec, MAX(able_date) as e_date  FROM `gwmonitor_docs` WHERE (state='draft') AND (receipt_user_code IS NULL) AND remind_start_date <= '#{Time.now.strftime('%Y-%m-%d %H:%M')}' GROUP BY `section_code`"
    items = Gwmonitor::Doc.find_by_sql(sql)
    for doc in items
      p "所属:#{doc.section_code}, 件数:#{doc.rec}件."
      title =  %Q[<a href="/gwmonitor">所属あて照会の未回答が #{doc.rec}件 あります。所属内で担当者を決定のうえ,回答してください。</a>]
      item = Gw::MonitorReminder.new
      item.and :g_code, doc.section_code
      reminder = item.find(:first)
      if reminder.blank?
        Gw::MonitorReminder.create({
        :state => 1,
        :g_code => doc.section_code,
        :title => title ,
        :ed_at => doc.e_date
      })
    else
      reminder.state = 1
      reminder.title = title
      reminder.ed_at = doc.e_date
      reminder.save
      end
    end
    dump "#{self}, 回答システム所属用リマインダ更新終了"
  end

  def self.renew_reminder_personal
    dump "#{self}, 回答システム個人用リマインダ更新開始"
    sql = "SELECT `receipt_user_code`, COUNT(id) as rec, MAX(able_date) as e_date  FROM `gwmonitor_docs` WHERE (state='editing') AND (receipt_user_code IS NOT NULL) AND remind_start_date_personal <= '#{Time.now.strftime('%Y-%m-%d %H:%M')}' GROUP BY `receipt_user_code`"
    items = Gwmonitor::Doc.find_by_sql(sql)
    for doc in items
      p "個人:#{doc.receipt_user_code}, 件数:#{doc.rec}件."
      title =  %Q[<a href="/gwmonitor">受取した照会の未回答が #{doc.rec}件 あります。</a>]
      item = Gw::MonitorReminder.new
      item.and :u_code, doc.receipt_user_code
      reminder = item.find(:first)
      if reminder.blank?
        Gw::MonitorReminder.create({
        :state => 1,
        :u_code => doc.receipt_user_code,
        :title => title ,
        :ed_at => doc.e_date
      })
    else
      reminder.state = 1
      reminder.title = title
      reminder.ed_at = doc.e_date
      reminder.save
      end
    end
    dump "#{self}, 回答システム個人用リマインダ更新終了"
  end

  def self.delete
    dump "#{self}, 回答システム (処理開始)"
    item = Gwmonitor::Itemdelete.new
    item.and :content_id, 0
    item = item.find(:first)
    dump "#{self}, 管理情報登録ない　終了." if item.blank?
    return if item.blank?
    dump "#{self}, 期間の設定がない　終了." if item.limit_date.blank?
    return if item.limit_date.blank?

    limit = self.get_limit_date(item.limit_date)
    return if limit.blank?

    self.destroy_record(limit)

    f_path = "#{Rails.root}/tmp/gwmonitor/"
    self.tmp_folder_workfile_delete(f_path)

    dump "#{self}, 回答システム記事削除(処理終了)"

    self.renew_reminder
  end

  def self.get_limit_date(limit_date)
    limit = Date.today
    case limit_date
    when "1.day"
      limit = limit.ago(1.day)
    when "1.month"
      limit = limit.months_ago(1)
    when "3.months"
      limit = limit.months_ago(3)
    when "6.months"
      limit = limit.months_ago(6)
    when "9.months"
      limit = limit.months_ago(9)
    when "12.months"
      limit = limit.months_ago(12)
    when "15.months"
      limit = limit.months_ago(15)
    when "18.months"
      limit = limit.months_ago(18)
    when "24.months"
      limit = limit.months_ago(24)
    else
      limit = ''
    end
    return limit
  end


  def self.destroy_record(limit)
    sql = Condition.new

    sql.or {|d|
      d.and :expiry_date, '<' , limit.strftime("%Y-%m-%d") + ' 00:00:00'
    }

    sql.or {|d|
      d.and :state, 'preparation'
    }
    item = Gwmonitor::Control.new
    items = item.find(:all, :conditions=>sql.where)
      del_count = 0
    for @title in items
      del_count += 1
      begin
        @title.destroy
      rescue => ex
        dump "#{self} : エラー発生 : #{ex.message}"
      end
    end
    dump "#{self}, 回答システム削除件数: #{del_count}"
  end

  def self.tmp_folder_workfile_delete(f_path)
    dirlist = Dir::glob(f_path + "**/").sort {
      |a,b| b.split('/').size <=> a.split('/').size
    }
    begin
    dirlist.each {|d|
      Dir::foreach(d) {|f|
      File::delete(d+f) if ! (/\.+$/ =~ f)
      }
      Dir::rmdir(d)
    }
    rescue
    end
  end

end
