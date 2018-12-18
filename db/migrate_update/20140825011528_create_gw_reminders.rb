class CreateGwReminders < ActiveRecord::Migration
  def change
    create_table :gw_reminders do |t|
      t.string   :state
      t.integer  :sort_no
      t.text     :title
      t.text     :name
      t.string   :css_name
      t.datetime :deleted_at
      t.text     :deleted_user
      t.text     :deleted_group
      t.datetime :updated_at
      t.text     :updated_user
      t.text     :updated_group
      t.datetime :created_at
      t.text     :created_user
      t.text     :created_group
    end
    add_index :gw_reminders, :state
  end
end
