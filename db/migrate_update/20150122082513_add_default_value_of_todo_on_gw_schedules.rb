class AddDefaultValueOfTodoOnGwSchedules < ActiveRecord::Migration
  def change
    change_column :gw_schedules, :todo, :integer, default: 0
  end
end
