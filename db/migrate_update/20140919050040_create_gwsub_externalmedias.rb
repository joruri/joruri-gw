class CreateGwsubExternalmedias < ActiveRecord::Migration
  def change
    create_table :gwsub_externalmedias do |t|
      t.integer  :new_registedno
      t.integer  :section_id
      t.string   :section_code
      t.text     :section_name
      t.text     :registedno
      t.integer  :externalmediakind_id
      t.string   :externalmediakind_name
      t.text     :registed_seq
      t.datetime :registed_at
      t.text     :equipmentname
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
    add_index :gwsub_externalmedias, :section_id
    add_index :gwsub_externalmedias, :externalmediakind_id
    add_index :gwsub_externalmedias, :user_section_id
    add_index :gwsub_externalmedias, :user_id
  end
end
