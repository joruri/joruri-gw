class AddDefaultValueOfTodoOnGwSchedules < ActiveRecord::Migration
  def change
    add_column :gw_schedules, :todo, :integer, default: 0
  end
end
