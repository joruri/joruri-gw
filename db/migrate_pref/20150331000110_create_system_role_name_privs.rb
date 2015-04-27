class CreateSystemRoleNamePrivs < ActiveRecord::Migration
  def change
    create_table "system_role_name_privs" do |t|
      t.integer  "role_id"
      t.integer  "priv_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "system_role_name_privs", ["priv_id"], name: "index_system_role_name_privs_on_priv_id", using: :btree
    add_index "system_role_name_privs", ["role_id"], name: "index_system_role_name_privs_on_role_id", using: :btree
  end
end
