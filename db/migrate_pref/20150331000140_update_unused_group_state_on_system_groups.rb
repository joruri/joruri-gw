class UpdateUnusedGroupStateOnSystemGroups < ActiveRecord::Migration
  def up
    execute "update system_groups set state = 'disabled' where id = 593"
  end
  def down
  end
end
