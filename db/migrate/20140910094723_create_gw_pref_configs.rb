class CreateGwPrefConfigs < ActiveRecord::Migration
  def change
    create_table :gw_pref_configs do |t|
      t.text     :state
      t.text     :option_type
      t.text     :name
      t.text     :options
      t.datetime :created_at
      t.text     :created_user
      t.text     :created_group
      t.datetime :updated_at
      t.text     :updated_user
      t.text     :updated_group
    end
  end
end
