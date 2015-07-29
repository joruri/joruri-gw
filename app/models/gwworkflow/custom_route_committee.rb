# -*- encoding: utf-8 -*-

class Gwworkflow::CustomRouteCommittee < Gw::Database
  set_table_name 'gw_workflow_custom_route_users'

  belongs_to :step, :class_name => 'Gwworkflow::CustomRouteStep', :foreign_key => :step_id,
    :autosave =>true, :touch => true
  
  def user_name_and_code
    u = user
    u ? user.name_and_code : ''
  end
  
  def user_enable?
    u = user
    return false unless u
    u.state == 'enabled'
 end
  
  def creatable?
    return true
  end

  def editable?
    return true
  end
  
  private
  def user
    System::User.find(user_id)
  end
end
