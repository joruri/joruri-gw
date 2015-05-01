class InsertIntoGwAccessControls < ActiveRecord::Migration
  def up
    execute "insert into gw_access_controls (state, user_id, path, priority) values ('enabled', 5431, '/gw/pref_only_assembly', 1)" 
    execute "insert into gw_access_controls (state, user_id, path, priority) values ('enabled', 5431, '/gw/pref_only_executives', 10)" 
    execute "insert into gw_access_controls (state, user_id, path, priority) values ('enabled', 5431, '/gw/pref_only_directors', 10)" 
    execute "insert into gw_access_controls (state, user_id, path, priority) values ('enabled', 5470, '/_admin/gw/link_sso/redirect_to_joruri?to=gw_ind&path=/pes', 1)" 
  end
  def down
  end
end
