class ChangeStateColumnTypeOnSystemUsersAndSystemGroupsAndSoOn < ActiveRecord::Migration
  def up
    change_column :system_users, :state, :string
    change_column :system_groups, :state, :string
    change_column :system_group_histories, :state, :string
    change_column :system_group_temporaries, :state, :string
    change_column :system_group_history_temporaries, :state, :string
  end
  def down
    change_column :system_users, :state, :text
    change_column :system_groups, :state, :text
    change_column :system_group_histories, :state, :text
    change_column :system_group_temporaries, :state, :text
    change_column :system_group_history_temporaries, :state, :text
  end
end
