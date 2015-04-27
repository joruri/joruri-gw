class CreateGwMeetingGuidePlaces < ActiveRecord::Migration
  def change
    create_table :gw_meeting_guide_places do |t|
      t.text    :state
      t.integer :sort_no
      t.text    :place
      t.text    :place_master
      t.integer :place_type
      t.integer :prop_id
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
