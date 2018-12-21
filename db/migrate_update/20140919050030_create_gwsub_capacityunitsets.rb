class CreateGwsubCapacityunitsets < ActiveRecord::Migration
  def change
    create_table :gwsub_capacityunitsets do |t|
      t.integer  :code_int
      t.text     :code
      t.text     :name
      t.datetime :updated_at
      t.text     :updated_user
      t.text     :updated_group
      t.datetime :created_at
      t.text     :created_user
      t.text     :created_group
    end
    add_index :gwsub_capacityunitsets, :code_int
  end
end
