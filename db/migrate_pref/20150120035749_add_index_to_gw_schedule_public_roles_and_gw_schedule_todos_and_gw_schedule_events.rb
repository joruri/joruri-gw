class AddIndexToGwSchedulePublicRolesAndGwScheduleTodosAndGwScheduleEvents < ActiveRecord::Migration
  def change
    add_index :gw_schedule_public_roles, :schedule_id
    #add_index :gw_schedule_todos, :schedule_id
    #add_index :gw_schedule_events, :schedule_id
  end
end
