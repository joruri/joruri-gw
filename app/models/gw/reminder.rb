class Gw::Reminder < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gw::Model::Operator::Name

  validates :state, :sort_no, :title, :name, :css_name, presence: true
  validates :name, uniqueness: { scope: :deleted_at }
  
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
end
