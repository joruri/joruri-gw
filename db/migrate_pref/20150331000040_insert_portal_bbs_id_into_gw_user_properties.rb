class InsertPortalBbsIdIntoGwUserProperties < ActiveRecord::Migration
  def up
    execute "insert into gw_user_properties (class_id, name, type_name, options) values (1, 'smartphone_portal_board', 'bbs', '48')"
  end
  def down
  end
end
