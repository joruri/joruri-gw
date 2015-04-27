class AddIndexToSystemRolesAndSoOn < ActiveRecord::Migration
  def change
    add_index :system_roles, [:table_name, :priv_name, :class_id, :uid, :idx], name: 'index_system_roles_on_table_name_and_priv_name_and_class_id_and'
    add_index :system_role_name_privs, :role_id
    add_index :system_role_name_privs, :priv_id
  end
end
