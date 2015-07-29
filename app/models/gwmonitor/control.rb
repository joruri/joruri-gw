# -*- encoding: utf-8 -*-
class Gwmonitor::Control < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwmonitor::Model::Systemname

  belongs_to :form , :foreign_key => :form_id  ,:class_name=>'Gwmonitor::Form'

  validates_presence_of :state, :able_date, :expiry_date
  after_validation :validate_title, :attached_file_check
  before_save :set_section_name, :set_form_name
  after_save  :save_groups_json, :commission_count_update, :send_request_mail , :renew_reminder_base
  after_destroy :commission_delete

  attr_accessor :_commission_state

  def validate_title
    if self.title.blank?
      errors.add :title, "件名を入力してください。"
      self.state = 'draft' unless self._commission_state == 'public'
    else
      str = self.title.to_s.gsub(/　/, '').strip
      if str.blank?
        errors.add :title, "スペースのみのタイトルは登録できません。"
        self.state = 'draft' unless self._commission_state == 'public'
      end
      unless str.blank?
        s_chk = self.title.gsub(/\r\n|\r|\n/, '')
        self.title = s_chk
        if 140 <= s_chk.split(//).size
          errors.add :title, "件名は140文字以内で記入してください。"
          self.state = 'draft' unless self._commission_state == 'public'
        end
      end
    end unless self.state == 'preparation'

    if self.able_date > self.expiry_date
      errors.add :expiry_date, "を確認してください。（期限日が作成日より前になっています。）"
      self.state = 'draft' unless self._commission_state == 'public'
    end unless self.able_date.blank? unless self.expiry_date.blank?
  end

  def attached_file_check
    return unless self.state == 'public'
    file_cnt = 0
    atch_cnt = 0
    item = Gwmonitor::BaseFile.new
    item.and :title_id , self.id
    item.and :parent_id , self.id
    files = item.find(:all)
    files.each do |file|
      str = sprintf("%08d",file.id)
      str = "#{str[0..3]}/#{str[4..7]}"
      parent_name = Util::CheckDigit.check(format('%07d', file.parent_id))
      file_name = "/#{sprintf('%06d',file.title_id)}/#{parent_name}/#{str}/#{CGI.escapeHTML((URI.encode(file.filename)))}"
      file_cnt += 1
      atch_cnt += 1 if self.caption.index(file_name)
    end
    
    if file_cnt != atch_cnt
      errors.add :state, "記事本文に添付されていないファイルが #{file_cnt - atch_cnt} ファイルあります。"
      self.state = 'draft' unless self._commission_state == 'public'
    end
  end

  def status_name
    str = ''
    str = '下書き' if self.state == 'draft'
    str = '配信済み' if self.state == 'public'
    str = '締め切り' if self.state == 'closed'
    str = '期限終了' if self.expiry_date < Time.now unless self.expiry_date.blank? if self.state == 'public'
    return str
  end

  def spec_config_name
    return [
      ['回答者のみ表示する', 0] ,
      ['他の回答者名を表示する', 3] ,
      ['他の回答者名と内容を表示する', 5]
    ]
  end

  def spec_config_name_status
    ret = ''
    ret = '回答者のみ表示する' if self.spec_config == 0
    ret = '他の回答者名を表示する' if self.spec_config == 3
    ret = '他の回答者名と内容を表示する' if self.spec_config == 5
    return ret
  end

  def admin_setting_name
    return [
      ['作成者が管理する', 0] ,
      ['所属で管理する', 1]
    ]
  end

  def admin_setting_status
    ret = ''
    ret = '作成者が管理する' if self.admin_setting == 0
    ret = '所属で管理する'   if self.admin_setting == 1
    return ret
  end

  def send_change_name
    return [["所属から選択","1"],["個人から選択","2"]]
  end

  def send_change_status
    ret = ''
    ret = '所属から選択' if self.send_change == '1'
    ret = '個人から選択'   if self.send_change == '2'
    return ret
  end

  def reminder_start_section_selected_name
    return '表示しない' if self.reminder_start_section == -999
    begin
      if self.reminder_start_section < 0
        ret = "配信日から#{self.reminder_start_section * -1}日後に表示"
      else
        if self.reminder_start_section == 0
          ret = "配信直後から表示する"
        else
          ret = "回答期限日の#{self.reminder_start_section}日前から表示"
        end
      end
    rescue
      ret = ''
    end
    return ret
  end

  def reminder_start_personal_selected_name
    return '表示しない' if self.reminder_start_personal == -999
    begin
      if self.reminder_start_section < 0
        ret = "配信日から#{self.reminder_start_section * -1}日後に表示"
      else
        if self.reminder_start_section == 0
          ret = "配信直後から表示する"
        else
          ret = "回答期限日の#{self.reminder_start_section}日前から表示"
        end
      end
    rescue
      ret = ''
    end
    return ret
  end

  def reminder_start_name
    return [
      ['配信直後から表示する', 0] ,
      ['配信日から1日後に表示', -1],
      ['配信日から2日後に表示', -2],
      ['配信日から3日後に表示', -3],
      ['配信日から4日後に表示', -4],
      ['配信日から5日後に表示', -5],
      ['回答期限日の1日前から表示', 1],
      ['回答期限日の2日前から表示', 2],
      ['回答期限日の3日前から表示', 3],
      ['回答期限日の4日前から表示', 4],
      ['回答期限日の5日前から表示', 5],
      ['表示しない', -999],
    ]
  end

  def show_path
    return "/gwmonitor/builders/#{self.id}"
  end

  def edit_path
    return "/gwmonitor/builders/#{self.id}/edit"
  end

  def update_path
    return "/gwmonitor/builders/#{self.id}"
  end

  def delete_path
    return "/gwmonitor/builders/#{self.id}"
  end

  def closed_path
    return "/gwmonitor/builders/#{self.id}/closed"
  end

  def reopen_path
    return "/gwmonitor/builders/#{self.id}/reopen"
  end

  def monitor_path
    return "/gwmonitor"
  end

  def builder_path
    return "/gwmonitor/builders"
  end

  def response_path
    return "/gwmonitor/#{self.id}/docs/"
  end

  def new_doc_path
    return "/gwmonitor/#{self.id}/docs/new"
  end

  def result_path
    return "/gwmonitor/#{self.id}/results"
  end

  def csv_export_path
    return "/gwmonitor/#{self.id}/csv_exports"
  end

  def file_export_path
    return "/gwmonitor/#{self.id}/file_exports"
  end

  def csv_export_path
    return "/gwmonitor/#{self.id}/csv_exports"
  end

  def csv_export_file_path
    return "/gwmonitor/#{self.id}/csv_exports/export_csv"
  end

  def gwmonitor_form_name
    return 'gwmonitor/admin/user_forms/' + self.form_name + '/'
  end

  def set_section_name
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
  end

  def set_form_name
    self.form_name = ''
    self.form_caption = ''

    form = Gwmonitor::Form.find_by_id(self.form_id)
    return if form.blank?

    self.form_name = form.form_name
    self.form_caption = form.form_caption
  end

  def save_groups_json
    self.all_records_status_update
    if self.send_change == '2'
      save_custom_readers_json
      save_readers_json
    else
      save_custom_groups_json
      save_reader_groups_json
    end
  end

  def save_custom_readers_json
    unless self.custom_readers_json.blank?
      objects = JsonParser.new.parse(self.custom_readers_json)
      objects.each do |object|
        users = get_user_items(object[1])
        users.each do |user|
          create_user_record(user)
        end
      end
    end
  end

  def save_readers_json
    unless self.readers_json.blank?
      objects = JsonParser.new.parse(self.readers_json)
      objects.each do |object|
        users = get_user_items(object[1])
        users.each do |user|
          create_user_record(user)
        end
      end
    end
  end

  def is_vender_user
    ret = false
    ret = true if Site.user.code.length <= 3
    ret = true if Site.user.code == 'gwbbs'
    return ret
  end

  def get_user_items(uid)
    item = System::User.new
    item.and "sql", "system_users.state = 'enabled'"
    item.and "sql", "system_users_groups.user_id = #{uid}"
    return item.find(:all,:select=>'system_users.id, system_users.code, system_users.name, system_users.email',
      :joins=>['inner join system_users_groups on system_users.id = system_users_groups.user_id'],
      :order=>'system_users.sort_no, system_users.code')
  end

  def create_user_record(user)
    s_state = 'preparation'
    s_state = 'draft' if self.state == 'public'
    s_state = 'closed' if self.state == 'closed'

    self.reminder_start_section = 0 if self.reminder_start_section.blank?
    remind_start_date = self.able_date
    remind_start_date = self.expiry_date - self.reminder_start_section.days unless self.reminder_start_section == 0

    self.reminder_start_personal = 0 if self.reminder_start_personal.blank?
    remind_start_date_personal = self.able_date
    remind_start_date_personal = self.expiry_date - self.reminder_start_personal.days unless self.reminder_start_personal == 0

    group_code = ''
    group_name = ''
    group_code = user.groups[0].code unless user.groups.blank?
    group_name = user.groups[0].name unless user.groups.blank?
    l2_group_code = ''
    l2_group_code = user.groups[0].parent.code unless user.groups[0].parent.blank? unless user.groups.blank?

    item = Gwmonitor::Doc.new
    item.and :title_id,  self.id
    item.and :send_division, 2
    item.and :user_code, user.code
    doc = item.find(:first)
    if doc.blank?

      Gwmonitor::Doc.create({
        :state => s_state,
        :title_id => self.id,
        :send_division => 2 ,
        :user_code => user.code,
        :user_name => user.name,
        :l2_section_code => l2_group_code,
        :section_code => group_code,
        :section_name => group_name,
        :section_sort => 0,
        :email => user.email ,
        :email_send => false ,
        :title => '',
        :body => '',
        :able_date => self.able_date,
        :expiry_date => self.expiry_date ,
        :createdate => self.createdate ,
        :creater_id => self.creater_id ,
        :creater => self.creater ,
        :createrdivision => self.createrdivision ,
        :createrdivision_id => self.createrdivision_id ,
        :remind_start_date => remind_start_date ,
        :remind_start_date_personal => remind_start_date_personal ,
        :attachmentfile => 0
      })
    else

      doc.state = s_state unless doc.state == 'editing' unless doc.state == 'qNA' unless doc.state == 'public'  #回答済み以外は下書きにする
      doc.user_code = user.code
      doc.user_name = user.name
      doc.l2_section_code = l2_group_code
      doc.section_code = group_code
      doc.section_name = group_name
      doc.section_sort = 0
      doc.able_date = self.able_date
      doc.expiry_date = self.expiry_date
      doc.createdate = self.createdate
      doc.creater_id = self.creater_id
      doc.creater = self.creater
      doc.createrdivision = self.createrdivision
      doc.createrdivision_id = self.createrdivision_id
      doc.remind_start_date = remind_start_date
      doc.remind_start_date_personal = remind_start_date_personal
      doc.save
    end
  end

  def save_custom_groups_json
    unless self.custom_groups_json.blank?
      objects = JsonParser.new.parse(self.custom_groups_json)
      objects.each do |object|
        self.create_records(object[1])
      end
    end
  end

  def save_reader_groups_json
    unless self.reader_groups_json.blank?
      objects = JsonParser.new.parse(self.reader_groups_json)
      objects.each do |object|
        self.create_records(object[1])
      end
    end
  end

  def all_records_status_update
    condition = "(title_id=#{self.id} AND state='draft') OR (title_id=#{self.id} AND state='editing') OR (title_id=#{self.id} AND state='closed')"
    Gwmonitor::Doc.update_all("state='preparation'", condition)
  end

  def create_records(group_id)
    if group_id.to_s == '0'
      create_all_group_records
    else
      group = Gwboard::Group.find_by_id(group_id)
      self.create_group_record(group) unless group.blank?
    end
  end

  def create_all_group_records
    groups = Gwboard::Group.level3_all
    for group in groups
      self.create_group_record(group)
    end
  end

  def create_group_record(group)
    s_state = 'preparation'
    s_state = 'draft' if self.state == 'public'
    s_state = 'closed' if self.state == 'closed'

    l2_group_code = ''
    l2_group_code = group.parent.code unless group.parent.blank?

    self.reminder_start_section = 0 if self.reminder_start_section.blank?
    remind_start_date = self.able_date
    if self.reminder_start_section <= 0
      remind_start_date = self.able_date.beginning_of_day - self.reminder_start_section.days
    else
      remind_start_date = self.expiry_date.beginning_of_day - self.reminder_start_section.days
    end

    self.reminder_start_personal = 0 if self.reminder_start_personal.blank?
    remind_start_date_personal = self.able_date
    remind_start_date_personal = self.expiry_date.beginning_of_day - self.reminder_start_personal.days unless self.reminder_start_personal == 0

    item = Gwmonitor::Doc.new
    item.and :title_id,  self.id
    item.and :section_code, group.code
    item.and :send_division, 1
    doc = item.find(:first)
    if doc.blank?

      Gwmonitor::Doc.create({
        :state => s_state,
        :title_id => self.id,
        :send_division => 1 ,
        :l2_section_code => l2_group_code,
        :section_code => group.code,
        :section_name => group.name,
        :section_sort => group.sort_no,
        :email => group.email ,
        :email_send => false ,
        :title => '',
        :body => '',
        :able_date => self.able_date,
        :expiry_date => self.expiry_date ,
        :createdate => self.createdate ,
        :creater_id => self.creater_id ,
        :creater => self.creater ,
        :createrdivision => self.createrdivision ,
        :createrdivision_id => self.createrdivision_id ,
        :remind_start_date => remind_start_date ,
        :remind_start_date_personal => remind_start_date_personal ,
        :attachmentfile => 0
      })
    else

      if doc.state == 'editing'
        doc.state = s_state  if s_state == 'closed'
      else
        doc.state = s_state unless doc.state == 'editing' unless doc.state == 'qNA' unless doc.state == 'public'  #回答済み(public,qNA,editing)以外は下書きにする
      end

      if self.state == 'public'
        doc.state = 'editing' if doc.state == 'draft' unless doc.editor.blank?
      end if s_state == 'draft'

      doc.l2_section_code = l2_group_code
      doc.section_code = group.code
      doc.section_name = group.name
      doc.section_sort = group.sort_no
      doc.able_date = self.able_date
      doc.expiry_date = self.expiry_date
      doc.createdate = self.createdate
      doc.creater_id = self.creater_id
      doc.creater = self.creater
      doc.createrdivision = self.createrdivision
      doc.createrdivision_id = self.createrdivision_id
      doc.remind_start_date = remind_start_date
      doc.remind_start_date_personal = remind_start_date_personal
      doc.save
    end
  end

  def commission_info
    self.public_count = 0 if self.public_count.blank?
    self.draft_count = 0 if self.draft_count.blank?
    ret = ''
    ret = "(#{self.public_count - self.draft_count}/#{self.public_count})" unless self.state == 'draft'
    return ret
  end

  def commission_count_update

    condition = "state !='preparation' AND title_id=#{self.id}"
    public_count = Gwmonitor::Doc.count(:conditions=>condition)

    condition = "(state='draft' AND title_id=#{self.id}) OR (state='closed' AND title_id=#{self.id}) OR (state='editing' AND title_id=#{self.id})"
    draft_count = Gwmonitor::Doc.count(:conditions=>condition)

    condition = "id=#{self.id}"
    Gwmonitor::Control.update_all("public_count=#{public_count},draft_count=#{draft_count}", condition)
  end

  def get_self_domain_name
    rails_env = ENV['RAILS_ENV']
    begin
      site = YAML.load_file('config/site.yml')
      @host = site[rails_env]['domain']
    rescue
    end
    return @host || request.server_name
  end

  def get_test_mail_address
    item = Gw::UserProperty.new
    item.and :class_id, 3
    item.and :name, 'gwmonitor'
    item.order :id
    mode = item.find(:first)
    return {:mode => false, :email => ''} if mode.blank?
    return {:mode => true, :email => ''} if mode.type_name == 'true'
    return {:mode => false, :email => ''} if mode.type_name == 'false'
    return {:mode => true, :email => mode.options} if mode.type_name == 'test'
    return {:mode => false, :email => ''} unless mode.type_name == 'test' unless mode.type_name == 'false' unless mode.type_name == 'true'
  end

  def send_request_mail
    return unless self.state == 'public'
    _mail = get_test_mail_address
    return unless _mail[:mode]

    domain_name = get_self_domain_name

    mail_fr = Site.user.email
    subject = "照会・回答システム：回答依頼メール"
    subject += "（テストモード）" unless _mail[:email].blank?
    message = "#{Site.user_group.name} #{Site.user.name}さんより\n" + "「#{self.title}」\n" + "についての回答依頼が届きました。\n\n" + "次のリンクから内容を確認し，回答してください。\n\n"
    message_under = "\n回答までの手順\n\n１ 所属内で回答する担当者を決定\n２ 担当者は,上記リンクから記事の内容を確認し,「受け取る」をクリック\n３ 回答期限までに担当者は,回答欄を編集し,「回答する」又は「該当なし」をクリック\n\n以上で完了です。"

    item = Gwmonitor::Doc.new
    item.and :title_id,  self.id
    item.and :state ,'draft'
    item.and :email_send, false
    items = item.find(:all)
    items.each do |r|
      unless r.email.blank?
        url = "http://#{domain_name}#{self.response_path}#{r.id}"
        unless _mail[:email].blank?
          send_msg = "#{message}#{url}\n\n#{message_under}\n\n------\n正式な送信先:#{r.email}\n------"
          Gw.send_mail(mail_fr, _mail[:email], subject, send_msg)
        else
          send_msg = "#{message}#{url}\n\n#{message_under}"
          Gw.send_mail(mail_fr, r.email, subject, send_msg)
        end
        r.email_send = true
        r.save
      end
    end
  end

  def commission_delete

    Gwmonitor::Doc.destroy_all("title_id=#{self.id}")
    Gwmonitor::File.destroy_all("title_id=#{self.id}")
    Gwmonitor::BaseFile.destroy_all("title_id=#{self.id}")
    Gwmonitor::Script::Task.renew_reminder
  end

  def renew_reminder_base
    item = Gwmonitor::Doc.new
    item.and :title_id,  self.id
    items = item.find(:all)
    items.each do |r|
      renew_reminder_section(r.section_code)
      renew_reminder_personal(r.receipt_user_code) unless r.receipt_user_code.blank?
    end
  end

  def renew_reminder_section(section_code)
    Gw::MonitorReminder.update_all("state=0,title=''", "g_code='#{section_code}'")

    sql = "SELECT `section_code`, COUNT(id) as rec, MAX(able_date) as e_date  FROM `gwmonitor_docs` WHERE (state='draft') AND (receipt_user_code IS NULL) AND (section_code='#{section_code}') AND remind_start_date <= '#{Time.now.strftime('%Y-%m-%d %H:%M')}' GROUP BY `section_code`"
    doc = Gwmonitor::Doc.find_by_sql(sql)
    return if doc.blank?
    title =  %Q[<a href="/gwmonitor">所属あて照会の未回答が #{doc[0].rec}件 あります。所属内で担当者を決定のうえ,回答してください。</a>]

    item = Gw::MonitorReminder.new
    item.and :g_code, section_code
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

  def renew_reminder_personal(user_code)
    Gw::MonitorReminder.update_all("state=0,title=''", "u_code='#{user_code}'")

    sql = "SELECT `receipt_user_code`, COUNT(id) as rec, MAX(able_date) as e_date  FROM `gwmonitor_docs` WHERE (state='editing') AND (receipt_user_code='#{user_code}') AND remind_start_date_personal <= '#{Time.now.strftime('%Y-%m-%d %H:%M')}' GROUP BY `receipt_user_code`"
    doc = Gwmonitor::Doc.find_by_sql(sql)
    return if doc.blank?
    title =  %Q[<a href="/gwmonitor">受取した照会の未回答が #{doc[0].rec}件 あります。</a>]

    item = Gw::MonitorReminder.new
    item.and :u_code, user_code
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
