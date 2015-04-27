class UpdateSudachiLinkIconOnGwEditTabs < ActiveRecord::Migration
  def up
    execute %|update gw_edit_tabs set name = concat('<img src="/_common/tiny_mce/plugins/prefemotions/img/link_sudachikun.gif"> ', name) where parent_id = 5|
  end
  def down
  end
end
