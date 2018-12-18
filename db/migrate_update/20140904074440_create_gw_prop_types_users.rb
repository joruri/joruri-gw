class CreateGwPropTypesUsers < ActiveRecord::Migration
  def change
    create_table :gw_prop_types_users do |t|
      t.integer  :user_id
      t.text  :user_name
      t.integer :type_id
      t.timestamps
    end
  end
end
