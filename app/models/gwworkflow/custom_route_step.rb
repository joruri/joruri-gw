class Gwworkflow::CustomRouteStep < Gw::Database
  self.table_name = 'gw_workflow_custom_route_steps'

  belongs_to :custom_route, :class_name => 'Gwworkflow::CustomRoute', :foreign_key => :custom_route_id,
    :autosave =>true, :touch => true
  has_many :committees, :class_name => 'Gwworkflow::CustomRouteCommittee', :foreign_key => :step_id,
    :dependent => :destroy

  def committee
    committees.first
  end
end
