class Gwworkflow::CustomRouteCommittee < Gw::Database
  self.table_name = 'gw_workflow_custom_route_users'

  belongs_to :step, :class_name => 'Gwworkflow::CustomRouteStep', :foreign_key => :step_id,
    :autosave => true, :touch => true
  belongs_to :user, :class_name => 'System::User', :foreign_key => :user_id

  def user_name_and_code
    user.try(:name_and_code)
  end

  def user_enable?
    user && user.state == 'enabled'
 end

  def creatable?
    return true
  end

  def editable?
    return true
  end
end
