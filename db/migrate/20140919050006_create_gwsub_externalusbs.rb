class CreateGwsubExternalusbs < ActiveRecord::Migration
  def change
    create_table :gwsub_externalusbs do |t|
      t.integer  :new_registedno
      t.integer  :section_id
      t.string   :section_code
      t.text     :section_name
      t.text     :registedno
      t.integer  :externalmediakind_id
      t.datetime :registed_at
      t.text     :equipmentname
      t.text     :capacity
      t.integer  :capacityunit_id
      t.text     :sendstate
      t.integer  :user_section_id
      t.integer  :user_id
      t.string   :user
      t.integer  :categories
      t.datetime :ending_at
      t.text     :remarks
      t.datetime :last_updated_at
      t.datetime :updated_at
      t.text     :updated_user
      t.text     :updated_group
      t.datetime :created_at
      t.text     :created_user
      t.text     :created_group
    end
    add_index :gwsub_externalusbs, :section_id
    add_index :gwsub_externalusbs, :externalmediakind_id
    add_index :gwsub_externalusbs, :capacityunit_id
    add_index :gwsub_externalusbs, :user_section_id
    add_index :gwsub_externalusbs, :user_id
  end
end
