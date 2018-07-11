class CreateGwPortalAddAccessLogs < ActiveRecord::Migration
  def change
    create_table :gw_portal_add_access_logs do |t|
      t.integer  :add_id
      t.datetime :accessed_at
      t.string   :ipaddr
      t.text     :user_agent
      t.text     :referer
      t.text     :path
      t.text     :content
      t.timestamps
    end
    add_index :gw_portal_add_access_logs, [:add_id, :accessed_at]
  end
end
