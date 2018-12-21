class AddScheduleParentIdIndexToGwSchedules < ActiveRecord::Migration
  def change
    add_index :gw_schedules, :schedule_parent_id
  end
end
