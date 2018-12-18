class UpdateParentIdForRootOnGwEditLinkPieces < ActiveRecord::Migration
  def up
    execute "update gw_edit_link_pieces set parent_id = NULL where parent_id = 0"
  end
  def down
  end
end
