class CreateGwScheduleFiles < ActiveRecord::Migration
  def change
    create_table :gw_schedule_files do |t|
      t.integer  :parent_id
      t.string   :tmp_id
      t.string   :content_type
      t.text     :file_name
      t.string   :file_path
      t.string   :file_directory
      t.string   :original_file_name
      t.text     :memo
      t.integer  :size
      t.integer  :width
      t.integer  :height
      t.timestamps null: false
    end
  end
end
