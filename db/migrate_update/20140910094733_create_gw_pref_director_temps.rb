class CreateGwPrefDirectorTemps < ActiveRecord::Migration
  def change
    create_table :gw_pref_director_temps do |t|
      t.integer  :parent_gid
      t.string   :parent_g_code
      t.string   :parent_g_name
      t.integer  :parent_g_order
      t.integer  :gid
      t.string   :g_code
      t.string   :g_name
      t.integer  :g_order
      t.integer  :uid
      t.string   :u_code
      t.text     :u_lname
      t.text     :u_name
      t.integer  :u_order
      t.text     :title
      t.string   :state
      t.datetime :deleted_at
      t.string   :deleted_user
      t.string   :deleted_group
      t.datetime :updated_at
      t.string   :updated_user
      t.string   :updated_group
      t.datetime :created_at
      t.string   :created_user
      t.string   :created_group
      t.integer  :is_governor_view
      t.integer  :display_parent_gid
      t.string   :version
    end
  end
end
