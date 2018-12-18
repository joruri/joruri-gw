class CreateGwSectionAdminMasterFuncNames < ActiveRecord::Migration
  def change
    create_table :gw_section_admin_master_func_names do |t|
      t.text     :func_name
      t.text     :name
      t.text     :state
      t.integer  :sort_no
      t.integer  :creator_uid
      t.integer  :creator_gid
      t.datetime :created_at
      t.integer  :updator_uid
      t.integer  :updator_gid
      t.datetime :updated_at
      t.integer  :deleted_uid
      t.integer  :deleted_gid
      t.datetime :deleted_at
    end
  end
end
