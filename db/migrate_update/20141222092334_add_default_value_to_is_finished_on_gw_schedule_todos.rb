class AddDefaultValueToIsFinishedOnGwScheduleTodos < ActiveRecord::Migration
  def change
    change_column :gw_schedule_todos, :is_finished, :integer, default: 0
  end
end
