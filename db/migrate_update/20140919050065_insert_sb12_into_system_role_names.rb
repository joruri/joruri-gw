class InsertSb12IntoSystemRoleNames < ActiveRecord::Migration
  def up
    execute "insert into system_role_names (display_name, table_name, sort_no) values ('媒体管理', 'sb12', 620)"
  end
  def down
  end
end
