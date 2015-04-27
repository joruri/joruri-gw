class Gwmonitor::Doc < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwmonitor::Model::Systemname
  include Gwmonitor::Model::Doc::Auth

  has_many :files, :foreign_key => :parent_id, :dependent => :destroy
  belongs_to :section, :foreign_key => :section_code, :primary_key => :code, :class_name => 'System::Group'
  belongs_to :control, :foreign_key => :title_id, :class_name => 'Gwmonitor::Control'

  with_options unless: :state_preparation? do |f|
    f.before_save :set_section_name_and_receipt_user_code, :set_attachmentfile_count
    f.after_update :update_commission_count, :renew_reminder
  end

  scope :without_preparation, -> { where.not(state: 'preparation') }
  scope :with_target_user, ->(user = Core.user) {
    where([
      arel_table[:send_division].eq(1).and( arel_table[:section_code].eq(user.groups.first.try(:code)) ),
      arel_table[:send_division].eq(2).and( arel_table[:user_code].eq(user.code) ),
    ].reduce(:or))
  }
  scope :without_target_user, ->(user = Core.user) {
    where.not([
      arel_table[:send_division].eq(1).and( arel_table[:section_code].eq(user.groups.first.try(:code)) ),
      arel_table[:send_division].eq(2).and( arel_table[:user_code].eq(user.code) ),
    ].reduce(:or))
  }

  def state_preparation?
    state == 'preparation'
  end

  def expired?
    (expiry_date && expiry_date < Time.now) || (control && control.state == 'closed')
  end

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

  def set_creater_editor
    self.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    self.editor_id = Core.user.code
    self.editor = Core.user.name
    self.editordivision = Core.user_group.name
    self.editordivision_id = Core.user_group.code
  end

  private

  def set_section_name_and_receipt_user_code
    self.section_name = section ? "#{section.code}#{section.name}" : ''
    self.section_sort = section ? section.sort_no : 0
    self.receipt_user_code = Core.user.code if self.receipt_user_code.blank? && self.state == 'editing'
  end

  def set_attachmentfile_count
    self.attachmentfile = files.count
  end

  def update_commission_count
    control.update_commission_count
  end

  def renew_reminder
    control.class.renew_reminder_section(self.section_code)
    control.class.renew_reminder_personal(self.receipt_user_code) if self.receipt_user_code.present?
  end
end
