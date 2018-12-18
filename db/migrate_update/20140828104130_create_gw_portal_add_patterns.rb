class CreateGwPortalAddPatterns < ActiveRecord::Migration
  def change
    create_table :gw_portal_add_patterns do |t|
      t.integer  :pattern
      t.integer  :place
      t.text     :state
      t.integer  :add_id
      t.integer  :sort_no
      t.integer  :group_id
      t.text     :title
      t.datetime :created_at
      t.text     :created_user
      t.text     :created_group
      t.datetime :updated_at
      t.text     :updated_user
      t.text     :updated_group
    end

    create_table :gw_portal_ad_daily_accesses do |t|
      t.text     :state
      t.integer  :ad_id
      t.text     :content
      t.integer  :click_count
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :accessed_at
    end
  end
end
