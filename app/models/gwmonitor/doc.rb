# -*- encoding: utf-8 -*-
class Gwmonitor::Doc < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwmonitor::Model::Systemname

  belongs_to :control, :foreign_key => :title_id, :class_name => 'Gwmonitor::Control'

  before_save :set_section_name_and_receipt_user_code, :set_attach_files_count
  after_save  :commission_count_update, :renew_reminder

  def status_name
    case self.state
    when 'closed'
      '<span style="display:block; text-align:center" class="required">未回答</span>'
    when 'draft'
      '<span style="display:block; text-align:center" class="required">受取待ち</span>'
    when 'editing'
      '<span style="display:block; text-align:center">受取済み</span>'
    when 'public'
      '<span style="display:block; text-align:center" class="notice">回答済</span>'
    when 'qNA'
      '<span style="display:block; text-align:center" class="notice">該当なし</span>'
    end
  end

  def status_name_show
    case self.state
    when 'closed'
      '<span class="required">未回答</span>'
    when 'draft'
      '<span class="required">受取待ち</span>'
    when 'editing'
      '受取済み'
    when 'public'
      '<span class="notice">回答済</span>'
    when 'qNA'
      '<span class="notice">該当なし</span>'
    end
  end

  def status_name_csv
    case self.state
    when 'closed'
      '未回答'
    when 'draft'
      '受取待ち'
    when 'editing'
      '受取済み'
    when 'public'
      '回答済'
    when 'qNA'
      '該当なし'
    end
  end

  def str_attache_span
    ret = ''
    ret = "<span>#{self.attachmentfile.to_s}</span>" if self.attachmentfile.to_s != '0'
    return ret
  end

  def already_state
    ret = ''
    ret = '?cond=already' unless self.state == 'draft'
    return ret
  end


  def show_path
    return "/#{self.system_name}/#{self.title_id}/docs/#{self.id}"
  end

  def edit_path
    return "/#{self.system_name}/#{self.title_id}/docs/#{self.id}/edit"
  end

  def update_path
    return "/#{self.system_name}/#{self.title_id}/docs/#{self.id}"
  end

  def result_show_path
    return "/#{self.system_name}/#{self.title_id}/results/#{self.id}"
  end

  def result_edit_path
    return "/#{self.system_name}/#{self.title_id}/results/#{self.id}/edit"
  end

  def result_update_path
    return "/#{self.system_name}/#{self.title_id}/results/#{self.id}"
  end

  def editing_path
    return "/#{self.system_name}/#{self.title_id}/docs/#{self.id}/editing_state_setting"
  end

  def draft_path
    return "/#{self.system_name}/#{self.title_id}/docs/#{self.id}/draft_state_setting"
  end

  def clone_path
    return "/#{self.system_name}/#{self.title_id}/docs/#{self.id}/clone"
  end

  def target_user_name
    ret = ''
    ret = self.section_name if self.send_division == 1
    ret = self.user_name if self.send_division == 2
    return ret
  end

  def target_user_code
    return ''
  end

  def display_editdate
    ret = ''
    ret = self.editdate.to_datetime.strftime('%Y-%m-%d %H:%M') unless self.editdate.blank?
    return ret
  end

  def set_section_name_and_receipt_user_code
    self.section_name = ''
    self.section_sort = 0

    group = Gwboard::Group.new
    group.and :state , 'enabled'
    group.and :code ,self.section_code
    group = group.find(:first)
    if group
      self.section_name = "#{group.code}#{group.name}"
      self.section_sort = group.sort_no
    end

    if self.state == 'editing'
      self.receipt_user_code = Site.user.code
    end if self.receipt_user_code.blank?
  end

  def set_attach_files_count
    self.attachmentfile = 0

    return if self.state == 'preparation'

    item = Gwmonitor::File.new
    item.and :title_id, self.title_id
    item.and :parent_id, self.id
    files = item.find(:all)
    self.attachmentfile = files.length unless files.blank?
  end

  def commission_count_update

    condition = "state !='preparation' AND title_id=#{self.title_id}"
    public_count = Gwmonitor::Doc.count(:conditions=>condition)

    condition = "(state='draft' AND title_id=#{self.title_id}) OR (state='closed' AND title_id=#{self.title_id}) OR (state='editing' AND title_id=#{self.title_id})"
    draft_count = Gwmonitor::Doc.count(:conditions=>condition)

    condition = "id=#{self.title_id}"
    Gwmonitor::Control.update_all("public_count=#{public_count},draft_count=#{draft_count}", condition)
  end

  def renew_reminder
    renew_reminder_section
    renew_reminder_personal
  end

  def renew_reminder_section
    Gw::MonitorReminder.update_all("state=0,title=''", "g_code='#{self.section_code}'")

    sql = "SELECT `section_code`, COUNT(id) as rec, MAX(able_date) as e_date  FROM `gwmonitor_docs` WHERE (state='draft') AND (receipt_user_code IS NULL) AND (section_code='#{self.section_code}') AND remind_start_date <= '#{Time.now.strftime('%Y-%m-%d %H:%M')}' GROUP BY `section_code`"
    doc = Gwmonitor::Doc.find_by_sql(sql)
    return if doc.blank?
    title =  %Q[<a href="/gwmonitor">所属あて照会の未回答が #{doc[0].rec}件 あります。所属内で担当者を決定のうえ,回答してください。</a>]

    item = Gw::MonitorReminder.new
    item.and :g_code, self.section_code
    reminder = item.find(:first)
    if reminder.blank?

      Gw::MonitorReminder.create({
      :state => 1,
      :g_code => doc[0].section_code,
      :title => title ,
      :ed_at => doc[0].e_date
      })
    else

      reminder.state = 1
      reminder.title = title
      reminder.ed_at = doc[0].e_date
      reminder.save
    end
  end

  def renew_reminder_personal
    Gw::MonitorReminder.update_all("state=0,title=''", "u_code='#{Site.user.code}'")

    sql = "SELECT `receipt_user_code`, COUNT(id) as rec, MAX(able_date) as e_date  FROM `gwmonitor_docs` WHERE (state='editing') AND (receipt_user_code='#{Site.user.code}') AND remind_start_date_personal <= '#{Time.now.strftime('%Y-%m-%d %H:%M')}' GROUP BY `receipt_user_code`"
    doc = Gwmonitor::Doc.find_by_sql(sql)
    return if doc.blank?
    title =  %Q[<a href="/gwmonitor">受取した照会の未回答が #{doc[0].rec}件 あります。</a>]

    item = Gw::MonitorReminder.new
    item.and :u_code, Site.user.code
    reminder = item.find(:first)
    if reminder.blank?

      Gw::MonitorReminder.create({
      :state => 1,
      :u_code => doc[0].receipt_user_code,
      :title => title ,
      :ed_at => doc[0].e_date
      })
    else

      reminder.state = 1
      reminder.title = title
      reminder.ed_at = doc[0].e_date
      reminder.save
    end
  end

end