class Gw::MeetingMonitorManager < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gw::Model::Operator::Name

  belongs_to :manager_user, :foreign_key => :manager_user_id, :class_name => 'System::User'

  validates :manager_user_addr, presence: true, 
    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "の形式が正しくありません。" }

  default_scope -> { where.not(state: 'deleted') }

  def self.is_admin?(user = Core.user)
    user.has_role?('_admin/admin')
  end

  def state_label
    self.class.state_show(state)
  end

  def self.state_select
    [['通知する','enabled'],['通知しない','disabled']]
  end

  def self.state_show(state)
    self.state_select.rassoc(state).try(:first)
  end
end
