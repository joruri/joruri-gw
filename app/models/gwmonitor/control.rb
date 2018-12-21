class Gwmonitor::Control < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwmonitor::Model::Systemname
  include Gwmonitor::Model::Control::Auth
  include Gwmonitor::Model::Control::Wiki

  with_options unless: :state_preparation? do |f|
    f.before_destroy :load_docs_before_destroy
  end

  has_many :docs, :foreign_key => :title_id, :dependent => :destroy
  belongs_to :form, :foreign_key => :form_id, :class_name => 'Gwmonitor::Form'
  belongs_to :section, :foreign_key => :section_code, :primary_key => :code, :class_name => 'System::Group'
  has_many :base_files, :foreign_key => :title_id, :dependent => :destroy
  has_many :files, :foreign_key => :title_id

  with_options unless: :state_preparation? do |f|
    f.before_save :set_section_name, :set_form_name, :set_creater_editor
    f.after_save :save_groups_json
    f.after_save :update_commission_count
    f.after_save :renew_reminder
    f.after_save :send_request_mail
    f.after_destroy :renew_reminder_after_destroy
  end

  with_options unless: :state_preparation? do |f|
    f.validates :state, :able_date, :expiry_date, presence: true
    f.validates :title, presence: { message: "件名を入力してください。" }, length: { maximum: 140, message: "タイトルは140文字以内で記入してください。" }
    f.validate :validate_date_order
    f.validate :validate_all_file_attached, if: :state_public?
  end

  scope :without_preparation, -> { where.not(state: 'preparation') }
  scope :with_admin_role, ->(user = Core.user) {
    where([
      arel_table[:admin_setting].eq(0).and( arel_table[:creater_id].eq(user.code) ),
      arel_table[:admin_setting].eq(1).and( arel_table[:section_code].eq(user.groups.first.try(:code)) ),
    ].reduce(:or))
  }

  def state_preparation?
    state == 'preparation'
  end

  def state_public?
    state == 'public'
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
      ['所属で管理する', 1],
      ['作成者が管理する', 0]
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

  def commission_info
    self.public_count = 0 if self.public_count.blank?
    self.draft_count = 0 if self.draft_count.blank?
    ret = ''
    ret = "(#{self.public_count - self.draft_count}/#{self.public_count})" unless self.state == 'draft'
    return ret
  end

  def is_readable?
    true
  end

  def compress_files(options = {encoding: 'Shift_JIS'})
    file_options = []
    docs.where.not(state: 'preparation').order(:section_sort, :l2_section_code, :section_code).each do |doc|
      doc.files.each.with_index(1) do |file, i|
        filename = if doc.send_division == 1
            "#{doc.l2_section_code}_#{doc.section_code}_#{i}_#{file.filename}"
          else
            "#{doc.l2_section_code}_#{doc.section_code}_#{doc.user_code}_#{i}_#{file.filename}"
          end
        file_options << {filename: filename, filepath: file.f_name}
      end
    end
    return nil if file_options.blank?

    Gw.compress_files(file_options, options)
  end

  def duplicate
    new_title = self.class.new
    new_title.attributes = self.attributes.except("id")
    new_title.unid = nil
    new_title.content_id = nil
    new_title.state = 'preparation'
    new_title.created_at = nil
    new_title.updated_at = nil
    new_title.latest_updated_at = nil
    new_title.section_code = Core.user_group.code
    new_title.section_name = Core.user_group.code + Core.user_group.name
    new_title.section_sort = Core.user_group.sort_no

    new_title.public_count = nil
    new_title.draft_count = nil

    new_title.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    new_title.creater_id = Core.user.code
    new_title.creater = Core.user.name
    new_title.createrdivision = Core.user_group.name
    new_title.createrdivision_id = Core.user_group.code

    new_title.editdate = nil
    new_title.editordivision_id = nil
    new_title.editordivision = nil
    new_title.editor_id = nil
    new_title.editor = nil
    new_title.default_limit = nil
    new_title.dsp_admin_name = nil
    new_title.send_change = nil
    new_title.custom_groups = nil
    new_title.custom_groups_json = nil
    new_title.reader_groups = nil
    new_title.reader_groups_json = nil
    new_title.custom_readers = nil
    new_title.custom_readers_json = nil
    new_title.readers = nil
    new_title.readers_json = nil

    return nil unless new_title.save

    base_files.each do |file|
      new_file = file.class.new
      new_file.attributes = file.attributes.except(:id)
      new_file.file = Sys::Lib::File::NoUploadedFile.new(file.f_name, filename: file.filename, mime_type: file.content_type)
      new_file.title_id = new_title.id
      new_file.parent_id = new_title.id
      new_file.db_file_id = -1
      new_file.save

      new_title.caption = new_title.caption.gsub(file.file_uri('gwmonitor_base'), new_file.file_uri('gwmonitor_base'))
    end

    new_title.update_columns(caption: new_title.caption) if new_title.caption_changed?
    new_title
  end

  def update_commission_count
    update_columns(
      public_count: docs.where.not(state: 'preparation').count,
      draft_count: docs.where(state: %w(draft closed editing)).count
    )
  end

  class << self
    def renew_reminder_section(section_code = nil)
      if section_code
        Gw::MonitorReminder.where(g_code: section_code).update_all(state: 0, title: '')
      else
        Gw::MonitorReminder.where.not(g_code: nil).update_all(state: 0, title: '')
      end

      docs = Gwmonitor::Doc.select("section_code, COUNT(id) as rec, MAX(able_date) as e_date")
        .where(state: 'draft', receipt_user_code: nil)
        .where(Gwmonitor::Doc.arel_table[:remind_start_date].lteq(Time.now)).group(:section_code)
      docs = docs.where(section_code: section_code) if section_code

      docs.each do |doc|
        reminder = Gw::MonitorReminder.where(g_code: doc.section_code).first || Gw::MonitorReminder.new(g_code: doc.section_code)
        reminder.state = 1
        reminder.title = %Q[<a href="/gwmonitor">所属あて照会の未回答が #{doc.rec}件 あります。所属内で担当者を決定のうえ,回答してください。</a>]
        reminder.ed_at = doc.e_date
        reminder.save
      end
    end

    def renew_reminder_personal(user_code = nil)
      if user_code
        Gw::MonitorReminder.where(u_code: user_code).update_all(state: 0, title: '')
      else
        Gw::MonitorReminder.where.not(u_code: nil).update_all(state: 0, title: '')
      end

      docs = Gwmonitor::Doc.select("receipt_user_code, COUNT(id) as rec, MAX(able_date) as e_date")
        .where(state: 'editing').where(Gwmonitor::Doc.arel_table[:remind_start_date_personal].lteq(Time.now))
        .group(:receipt_user_code)
      docs = docs.where(receipt_user_code: user_code) if user_code

      docs.each do |doc|
        reminder = Gw::MonitorReminder.where(u_code: doc.receipt_user_code).first || Gw::MonitorReminder.new(u_code: doc.receipt_user_code)
        reminder.state = 1
        reminder.title = %Q[<a href="/gwmonitor">受取した照会の未回答が #{doc.rec}件 あります。</a>]
        reminder.ed_at = doc.e_date
        reminder.save
      end
    end
  end

  private

  def validate_date_order
    if self.able_date && self.expiry_date && self.able_date > self.expiry_date
      errors.add :expiry_date, "を確認してください。（期限日が作成日より前になっています。）"
    end
  end

  def validate_all_file_attached
    unattached = 0
    base_files.each do |file|
      unattached += 1 unless self.caption.index(file.file_uri('gwmonitor_base'))
    end

    if unattached != 0
      errors.add :base, "記事本文に添付されていないファイルが #{unattached} ファイルあります。"
    end
  end

  def set_creater_editor
    self.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    unless self.class.is_sysadm?
      self.section_code = Core.user_group.code
      self.creater_id = Core.user.code
      self.creater = Core.user.name
      self.createrdivision = Core.user_group.name
      self.createrdivision_id = Core.user_group.code
    end
  end

  def set_section_name
    if section
      self.section_name = "#{section.code}#{section.name}"
      self.section_sort = section.sort_no
    end
  end

  def set_form_name
    self.form_name = form.try(:form_name)
    self.form_caption = form.try(:form_caption)
  end

  def save_groups_json
    docs.where(state: %w(draft editing closed)).update_all(state: 'preparation')

    if self.send_change == '2'
      save_custom_readers_json
      save_readers_json
    else
      save_custom_groups_json
      save_reader_groups_json
    end
  end

  def save_custom_readers_json
    return if self.custom_readers_json.blank?

    uids = JSON.parse(self.custom_readers_json).map{|o| o[1]}
    System::User.select(:id, :code, :name, :email).where(id: uids, state: 'enabled').order(:sort_no, :code).all.each do |user|
      create_user_doc(user)
    end
  end

  def save_readers_json
    return if self.readers_json.blank?

    uids = JSON.parse(self.readers_json).map{|o| o[1]}
    System::User.select(:id, :code, :name, :email).where(id: uids, state: 'enabled').order(:sort_no, :code).all.each do |user|
      create_user_doc(user)
    end
  end

  def reminder_start_date
    if self.reminder_start_section.to_i <= 0
      self.able_date.beginning_of_day - self.reminder_start_section.to_i.days
    else
      self.expiry_date.beginning_of_day - self.reminder_start_section.to_i.days
    end
  end

  def reminder_start_date_personal
    if self.reminder_start_personal.to_i <= 0
      self.able_date.beginning_of_day - self.reminder_start_personal.to_i.days
    else
      self.expiry_date.beginning_of_day - self.reminder_start_personal.to_i.days
    end
  end

  def create_user_doc(user)
    s_state = case self.state
      when 'public' then 'draft'
      when 'closed' then 'closed'
      else 'preparation'
      end

    doc = docs.where(send_division: 2, user_code: user.code).first ||
          docs.build(send_division: 2, user_code: user.code, email: user.email, email_send: false, title: '', body: '')
    if doc.new_record?
      doc.state = s_state
    else
      doc.state = s_state if doc.state != 'editing' && doc.state != 'qNA' && doc.state != 'public'  #回答済み以外は下書きにする
    end
    doc.user_code = user.code
    doc.user_name = user.name
    doc.l2_section_code = user.groups.first.try(:parent).try(:code)
    doc.section_code = user.groups.first.try(:code)
    doc.section_name = user.groups.first.try(:name)
    doc.section_sort = 0
    doc.able_date = self.able_date
    doc.expiry_date = self.expiry_date
    doc.createdate = self.createdate
    doc.creater_id = self.creater_id
    doc.creater = self.creater
    doc.createrdivision = self.createrdivision
    doc.createrdivision_id = self.createrdivision_id
    doc.remind_start_date = reminder_start_date
    doc.remind_start_date_personal = reminder_start_date_personal
    doc.save
  end

  def save_custom_groups_json
    return if self.custom_groups_json.blank?
    JSON.parse(self.custom_groups_json).each {|o| create_group_docs(o[1]) }
  end

  def save_reader_groups_json
    return if self.reader_groups_json.blank?
    JSON.parse(self.reader_groups_json).each {|o| create_group_docs(o[1]) }
  end

  def create_group_docs(group_id)
    if group_id.to_s == '0'
      create_all_group_docs
    else
      group = System::Group.find_by(id: group_id)
      create_group_doc(group) if group
    end
  end

  def create_all_group_docs
    Gwboard::Group.level3_all.each {|group| create_group_doc(group) }
  end

  def create_group_doc(group)
    s_state = case self.state
      when 'public' then 'draft'
      when 'closed' then 'closed'
      else 'preparation'
      end

    doc = docs.where(send_division: 1, section_code: group.code).first ||
          docs.build(send_division: 1, section_code: group.code, email: group.email, email_send: false, title: '', body: '')
    if doc.new_record?
      doc.state = s_state
    else
      if doc.state == 'editing'
        doc.state = s_state if s_state == 'closed'
      else
        doc.state = s_state if doc.state != 'editing' && doc.state != 'qNA' && doc.state != 'public'  #回答済み(public,qNA,editing)以外は下書きにする
      end
      if doc.state == 'draft' && doc.editor.present? && self.state == 'public'
        doc.state = 'editing'
      end
    end
    doc.l2_section_code = group.parent.try(:code)
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
    doc.remind_start_date = reminder_start_date
    doc.remind_start_date_personal = reminder_start_date_personal
    doc.save
  end

  def renew_reminder
    gcodes = docs.map(&:section_code)
    ucodes = docs.map(&:receipt_user_code)
    self.class.renew_reminder_section(gcodes) if gcodes.present?
    self.class.renew_reminder_section(ucodes) if ucodes.present?
  end

  def load_docs_before_destroy
    @destroy_docs = docs.all.to_a
  end

  def renew_reminder_after_destroy
    gcodes = @destroy_docs.map(&:section_code)
    ucodes = @destroy_docs.map(&:receipt_user_code)
    self.class.renew_reminder_section(gcodes) if gcodes.present?
    self.class.renew_reminder_section(ucodes) if ucodes.present?
  end

  def send_request_mail
    if self.state == 'public'
      self.class.delay(queue: 'gwmonitor').send_request_mail(id, Core.user.id)
    end
  end

  def self.send_request_mail(id, from_user_id)
    item = self.find_by(id: id)
    return unless item

    from_user = System::User.find_by(id: from_user_id)
    return if !from_user || from_user.email.blank?

    test = Gwmonitor::Property::TestMailAddress.first_or_new

    count = 0
    sleep_time = Joruri.config.application['gwmonitor.request_mail_sleep_time'].presence || 0

    item.docs.where(state: 'draft', email_send: false).all.each do |doc|
      next if doc.email.blank?

      Gwmonitor::Mailer.request_mail(from: from_user.email, to: test.options_value.presence || doc.email,
        subject: "照会・回答システム：回答依頼メール", doc: doc, from_user: from_user).deliver
      doc.update_columns(email_send: true)

      count += 1
      sleep sleep_time
    end
  end
end
