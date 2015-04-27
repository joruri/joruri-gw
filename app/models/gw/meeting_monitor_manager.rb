class Gw::MeetingMonitorManager < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :manager_user, :foreign_key => :manager_user_id, :class_name => 'System::User'

  before_create :set_creator
  before_update :set_updator

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

  private

  def set_creator
    self.created_user  = Core.user.name
    self.created_group = Core.user_group.name
  end

  def set_updator
    self.updated_user  = Core.user.name
    self.updated_group = Core.user_group.name
  end
end
