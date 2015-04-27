class CopyValuesFromGwsubSb01TrainingBoardsToGwUserProperties < ActiveRecord::Migration
  def change
    execute <<-SQL
      insert into gw_user_properties (class_id, name, type_name, options) 
        select 1, 'gwsub_training_board', 'bbs', bbs_rel_id from gwsub_sb01_training_boards;
    SQL
  end
end
