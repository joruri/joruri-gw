class CreateGwDcnApprovals < ActiveRecord::Migration
  def change
    create_table :gw_dcn_approvals do |t|
      t.integer  :state
      t.integer  :uid
      t.string   :u_code
      t.integer  :gid
      t.string   :g_code
      t.integer  :class_id
      t.text     :title
      t.datetime :st_at
      t.datetime :ed_at
      t.integer  :is_finished
      t.integer  :is_system
      t.text     :author
      t.text     :options
      t.text     :body
      t.datetime :deleted_at
      t.datetime :updated_at
      t.datetime :created_at
    end
  end
end
