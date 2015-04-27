class AddIndexToGwmonitor < ActiveRecord::Migration
  def change
    add_index :gwmonitor_docs, :title_id
    add_index :gwmonitor_base_files, :title_id
    add_index :gwmonitor_files, :title_id
    add_index :gwmonitor_files, :parent_id
    add_index :gwmonitor_custom_groups, :owner_uid
    add_index :gwmonitor_custom_user_groups, :owner_uid
  end
end
