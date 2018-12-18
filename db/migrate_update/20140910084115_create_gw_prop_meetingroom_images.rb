class CreateGwPropMeetingroomImages < ActiveRecord::Migration
  def change
    create_table :gw_prop_meetingroom_images do |t|
      t.integer :parent_id
      t.integer :idx
      t.string :note, :limit=>255
      t.string :path, :limit=>255
      t.string :orig_filename, :limit=>255
      t.string :content_type, :limit=>255
      t.timestamps
    end
  end
end
