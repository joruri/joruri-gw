class CreateGwScheduleEventMasters < ActiveRecord::Migration
  def change
    create_table :gw_schedule_event_masters do |t|
      t.integer  :edit_auth
      t.integer  :management_parent_gid
      t.integer  :management_gid
      t.integer  :management_uid
      t.integer  :range_class_id
      t.integer  :division_parent_gid
      t.integer  :division_gid
      t.integer  :creator_uid
      t.integer  :creator_gid
      t.integer  :updator_uid
      t.integer  :updator_gid
      t.timestamps
    end
  end
end
