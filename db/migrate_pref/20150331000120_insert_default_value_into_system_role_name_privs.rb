class InsertDefaultValueIntoSystemRoleNamePrivs < ActiveRecord::Migration
  def up
    execute <<-SQL
      insert into system_role_name_privs (role_id, priv_id) 
        select rn.id, pn.id from system_roles as r
          inner join system_role_names as rn on rn.table_name = r.table_name
          inner join system_priv_names as pn on pn.priv_name = r.priv_name
          group by r.table_name, r.priv_name;
    SQL
  end
  def down
  end
end
