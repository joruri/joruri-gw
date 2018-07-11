class ModifyRootParentIdOnSystemGroups < ActiveRecord::Migration
  def change
    execute "update system_groups set parent_id = NULL where parent_id = 0"
  end
end
