class AddIndexToGwScheduleProps < ActiveRecord::Migration
  def change
    add_index :gw_schedule_props, :schedule_id
    #add_index :gw_schedule_props, :prop_type
    add_index :gw_schedule_props, [:prop_id, :prop_type]
  end
end
