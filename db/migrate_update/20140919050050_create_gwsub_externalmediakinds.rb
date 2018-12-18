class CreateGwsubExternalmediakinds < ActiveRecord::Migration
  def change
    create_table :gwsub_externalmediakinds do |t|
      t.integer  :sort_order_int
      t.text     :sort_order
      t.text     :kind
      t.text     :name
      t.datetime :updated_at
      t.text     :updated_user
      t.text     :updated_group
      t.datetime :created_at
      t.text     :created_user
      t.text     :created_group
    end
    add_index :gwsub_externalmediakinds, :sort_order_int
  end
end
