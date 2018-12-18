class UpdateParentIdForRootOnGwEditTabs < ActiveRecord::Migration
  def up
    execute "update gw_edit_tabs set parent_id = NULL where parent_id = 0"
  end
  def down
  end
end
