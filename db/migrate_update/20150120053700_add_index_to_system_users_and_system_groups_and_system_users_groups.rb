class AddIndexToSystemUsersAndSystemGroupsAndSystemUsersGroups < ActiveRecord::Migration
  def change
    add_index :system_users, :ldap
    add_index :system_users, :state
    add_index :system_groups, :code
    add_index :system_groups, :ldap
    add_index :system_groups, :state
    add_index :system_users_groups, :user_id
    add_index :system_users_groups, :group_id
  end
end
