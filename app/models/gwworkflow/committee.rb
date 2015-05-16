class Gwworkflow::Committee < Gw::Database
  self.table_name = 'gw_workflow_route_users'
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :step, :class_name => 'Gwworkflow::Step', :foreign_key => :step_id
  belongs_to :user, :class_name => 'System::User', :foreign_key => :user_id

  scope :with_committee, ->(user = Core.user) { where(user_id: user.id) }
  scope :with_undecided, -> { where(state: 'undecided') }
  scope :with_accepted, -> { where(state: 'accepted') }
  scope :with_remanded, -> { where(state: 'remanded') }
  scope :with_rejected, -> { where(state: 'rejected') }
  scope :with_processed, -> { where(state: ['accepted', 'remanded', 'rejected']) }

  def state_str
    case state.to_sym
    when :accepted then '承認'
    when :remanded then '差し戻し'
    when :rejected then '却下'
    else
      (step && step.doc.current_step && step.doc.current_step.committee.id) == id ? '処理中' : ''
    end
  end

  def user_name_and_code
    user.try(:name_and_code)
  end
end
