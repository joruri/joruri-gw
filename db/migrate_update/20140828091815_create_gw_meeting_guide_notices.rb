class CreateGwMeetingGuideNotices < ActiveRecord::Migration
  def change
    create_table :gw_meeting_guide_notices do |t|
      t.string :published, :limit => 255
      t.string :state, :limit => 255
      t.integer :sort_no
      t.text :title
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
