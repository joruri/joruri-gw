class UpdateTodoOnGwSchedules < ActiveRecord::Migration
  def change
    execute "update gw_schedules set todo = 0 where todo is null"
  end
end
