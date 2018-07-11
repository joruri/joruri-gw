class CreateGwPropMeetingrooms < ActiveRecord::Migration
  def change
    create_table :gw_prop_meetingrooms do |t|
      t.integer :sort_no
      t.integer :type_id
      t.integer :delete_state
      t.integer :reserved_state
      t.string :name, :limit=>255
      t.string :position, :limit=>255
      t.string :tel, :limit=>255
      t.integer :max_person
      t.integer :max_tables
      t.integer :max_chairs
      t.string :note, :limit=>255
      t.string :extra_flag
      t.text :extra_data
      t.string :gid, :limit=>255
      t.string :gname, :limit=>255
      t.timestamps
    end
  end
end
