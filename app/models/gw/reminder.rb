class Gw::Reminder < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  
  validates :state, :sort_no, :title, :name, :css_name, presence: true
  validates :name, uniqueness: { scope: :deleted_at }
  
  before_create :set_creator
  before_update :set_updator

  default_scope { where.not(state: 'deleted') }

  def states
    [['表示中','enabled'],['非表示','disabled']]
  end
  
  def show_state
    str = states.rassoc(self.state)
    str ? str[0] : ''
  end
  
  def self.is_admin?(user = Core.user)
    user.has_role?('_admin/admin') 
  end
  
  private

  def set_creator
    self.created_user  = Core.user.name
    self.created_group = Core.user_group.name
    self.updated_user  = Core.user.name
    self.updated_group = Core.user_group.name
  end
  
  def set_updator
    self.updated_user  = Core.user.name        
    self.updated_group = Core.user_group.name
  end
end