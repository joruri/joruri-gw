class CreateGwMeetingMonitorManagers < ActiveRecord::Migration
  def change
    create_table :gw_meeting_monitor_managers do |t|
      t.integer :manager_group_id
      t.integer :manager_user_id
      t.text     :manager_user_addr
      t.text     :state
      t.text     :created_user
      t.text     :updated_user
      t.text     :deleted_user
      t.text     :created_group
      t.text     :updated_group
      t.text     :deleted_group
      t.datetime :deleted_at
      t.integer :deleted_uid
      t.integer :deleted_gid
      t.datetime :updated_at
      t.integer :updated_uid
      t.integer :updated_gid
      t.datetime :created_at
      t.integer :created_uid
      t.integer :created_gid
      t.timestamps
    end
  end
end
