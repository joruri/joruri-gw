class AddIndexToGwUserProperties < ActiveRecord::Migration
  def change
    add_index :gw_user_properties, [:class_id, :uid, :name, :type_name],
      name: 'idx_gw_user_properties_searches',
      length: { uid: 20, state: 30, type_name: 30 }
  end
end
