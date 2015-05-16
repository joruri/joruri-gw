class Gwworkflow::CustomRouteCommittee < Gw::Database
  self.table_name = 'gw_workflow_custom_route_users'
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :step, :class_name => 'Gwworkflow::CustomRouteStep', :foreign_key => :step_id
  belongs_to :user, :class_name => 'System::User', :foreign_key => :user_id

  def user_name_and_code
    user.try(:name_and_code)
  end
end
