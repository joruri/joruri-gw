class CreateGwMeetingMonitorSettings < ActiveRecord::Migration
  def change
    create_table :gw_meeting_monitor_settings do |t|
      t.text     :state
      t.text     :mail_from
      t.text     :mail_title
      t.text     :mail_body
      t.text     :notice_body
      t.text     :conditions
      t.text     :weekday_notice
      t.text     :holiday_notice
      t.integer :monitor_type
      t.text     :name
      t.text     :ip_address
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
