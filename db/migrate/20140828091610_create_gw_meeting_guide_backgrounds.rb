class CreateGwMeetingGuideBackgrounds < ActiveRecord::Migration
  def change
    create_table :gw_meeting_guide_backgrounds do |t|
      t.string   :published, :limit=>255
      t.string   :state, :limit=>255
      t.integer :area
      t.integer :sort_no
      t.text     :file_path
      t.text     :file_directory
      t.text     :file_name
      t.text     :original_file_name
      t.string   :content_type, :limit=>255
      t.string   :background_color, :limit=>255
      t.text     :caption
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
