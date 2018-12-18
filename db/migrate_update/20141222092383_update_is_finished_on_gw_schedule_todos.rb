class UpdateIsFinishedOnGwScheduleTodos < ActiveRecord::Migration
  def change
    execute "update gw_schedule_todos set is_finished = 0 where is_finished is null"
  end
end
