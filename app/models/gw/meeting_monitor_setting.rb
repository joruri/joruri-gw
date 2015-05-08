class Gw::MeetingMonitorSetting < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gw::Model::Operator::Name

  validates :name, :ip_address, presence: true
  validates :mail_from, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, 
    message: "の形式が、メールアドレスではありません。" }, allow_blank: true
  validates :ip_address, uniqueness: { scope: [:monitor_type, :deleted_at] }

  default_scope -> { where.not(conditions: 'deleted') }

  def state_label
    self.class.state_show(state)
  end

  def self.state_select
    [['停止中','off'],['監視中','on']]
  end

  def self.state_show(state)
    self.state_select.rassoc(state).try(:first)
  end

  def conditions_label
    self.class.conditions_show(conditions)
  end

  def self.conditions_select
    [['有効','enabled'],['無効','disabled']]
  end

  def self.conditions_show(condition)
    self.conditions_select.rassoc(condition).try(:first)
  end

  def monitor_type_label
    self.class.system_show(monitor_type)
  end

  def self.system_select
    [['会議等案内システム',1],['出退表示システム',2]]
  end

  def self.system_show(system)
    self.system_select.rassoc(system).try(:first)
  end

  def weekday_notice_label
    self.class.weekday_show(weekday_notice)
  end

  def self.weekday_select
    [['通知を行う','on'],['通知を行わない','off']]
  end

  def self.weekday_show(setting)
    self.weekday_select.rassoc(setting).try(:first)
  end

  def holiday_notice_label
    self.class.holiday_show(holiday_notice)
  end

  def self.holiday_select(all=nil)
    [['通知を行う','on'],['通知を行わない','off']]
  end

  def self.holiday_show(setting)
    self.holiday_select.rassoc(setting).try(:first)
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('_admin/admin')
  end
end
