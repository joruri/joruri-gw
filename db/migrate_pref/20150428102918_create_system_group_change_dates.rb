class CreateSystemGroupChangeDates < ActiveRecord::Migration
  def change
    create_table "system_group_change_dates", force: true do |t|
      t.datetime "created_at"
      t.text     "created_user"
      t.text     "created_group"
      t.datetime "updated_at"
      t.text     "updated_user"
      t.text     "updated_group"
      t.datetime "deleted_at"
      t.text     "deleted_user"
      t.text     "deleted_group"
      t.datetime "start_at"
    end
  end
end
