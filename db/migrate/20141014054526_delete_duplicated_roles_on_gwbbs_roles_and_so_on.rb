class DeleteDuplicatedRolesOnGwbbsRolesAndSoOn < ActiveRecord::Migration
  def change
    [:gwbbs_roles, :gwfaq_roles, :gwqa_roles, :doclibrary_roles, :digitallibrary_roles, :gwcircular_roles].each do |table|
      execute "delete r1 from #{table} r1, #{table} r2 where r1.role_code = 'r' and r2.role_code = 'w' and r1.title_id = r2.title_id and r1.user_id = r2.user_id and r1.user_id is not null and r2.user_id is not null"
      execute "delete r1 from #{table} r1, #{table} r2 where r1.role_code = 'r' and r2.role_code = 'w' and r1.title_id = r2.title_id and r1.group_id = r2.group_id and r1.user_id is null and r2.user_id is null"
    end
  end
end
