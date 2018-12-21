class AddIndexToGwciruclar < ActiveRecord::Migration
  def change
    add_index :gwcircular_adms, :title_id
    add_index :gwcircular_roles, :title_id
    add_index :gwcircular_docs, :title_id
    add_index :gwcircular_files, :title_id
    add_index :gwcircular_files, :parent_id
    add_index :gwcircular_custom_groups, :owner_uid
  end
end
