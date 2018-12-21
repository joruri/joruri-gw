class MigrateGwbbsAdmsToGwbbsRolesAndSoOn < ActiveRecord::Migration
  def change
    [:gwbbs, :gwfaq, :gwqa, :doclibrary, :digitallibrary, :gwcircular].each do |mod|
      execute "insert into #{mod}_roles (title_id, user_id, user_code, user_name, group_id, group_code, group_name, created_at, role_code) select title_id, user_id, user_code, user_name, group_id, group_code, group_name, created_at, 'a' from #{mod}_adms"
      execute "update #{mod}_roles set user_id = NULL where user_id = 0"
    end
  end
end
