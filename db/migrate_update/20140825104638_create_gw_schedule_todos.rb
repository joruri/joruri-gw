#20140825104638
class CreateGwScheduleTodos < ActiveRecord::Migration
  def change
    create_table :gw_schedule_todos do |t|
      t.integer  "schedule_id"
      t.datetime "st_at"
      t.datetime "ed_at"
      t.integer  "todo_ed_at_indefinite", default: 0, null: false
      t.integer  "is_finished"
      t.integer  "todo_st_at_id",         default: 0
      t.integer  "todo_ed_at_id",         default: 0
      t.integer  "todo_repeat_time_id",   default: 0
      t.datetime "finished_at"
      t.integer  "finished_uid"
      t.integer  "finished_gid"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "todo_id"
      t.timestamps
    end
    Gw::EditLinkPiece.where(:link_url => "/gw/todos").update_all(:link_url => "/gw/schedule_todos")
    Gw::EditLinkPiece.where(:link_url => "/gw/todos/new").update_all(:link_url => "/gw/schedules/new?link=todo")
  end
end
