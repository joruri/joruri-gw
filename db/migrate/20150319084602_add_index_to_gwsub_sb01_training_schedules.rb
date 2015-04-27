class AddIndexToGwsubSb01TrainingSchedules < ActiveRecord::Migration
  def change
    [:gwsub_sb01_training_schedules, :gwsub_sb01_training_schedule_members, :gwsub_sb01_training_schedule_conditions].each do |table|
      add_index table, :training_id
    end
    add_index :gwsub_sb01_training_files, :parent_id

  end
end
