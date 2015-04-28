class CreateSystemUsersGroupsCsvdata < ActiveRecord::Migration
  def change
    create_table "system_users_groups_csvdata", force: true do |t|
      t.string   "state",             null: false
      t.string   "data_type",         null: false
      t.integer  "level_no"
      t.integer  "parent_id",         null: false
      t.string   "parent_code",       null: false
      t.string   "code",              null: false
      t.integer  "sort_no"
      t.integer  "ldap",              null: false
      t.integer  "job_order"
      t.text     "name",              null: false
      t.text     "name_en"
      t.text     "kana"
      t.string   "password"
      t.integer  "mobile_access"
      t.string   "mobile_password"
      t.string   "email"
      t.string   "official_position"
      t.string   "assigned_job"
      t.datetime "start_at",          null: false
      t.datetime "end_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
