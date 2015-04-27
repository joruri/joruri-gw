class InsertDisasterBbsValueToGwUserProperties < ActiveRecord::Migration
  def change
    execute "insert into gw_user_properties (class_id, name, type_name, options) values (3, 'portal', 'disaster_bbs', 36)"
  end
end
