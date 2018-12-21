class CreateGwPropTypesMessages < ActiveRecord::Migration
  def change
    create_table :gw_prop_types_messages do |t|
      t.integer :state
      t.integer :sort_no
      t.integer :state
      t.text :body
      t.integer :type_id
      t.timestamps
    end
  end
end
