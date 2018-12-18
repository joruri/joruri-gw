class InsertDefaultValuesIntoGwSectionAdminMasterFuncNames < ActiveRecord::Migration
  def up
    execute "insert into gw_section_admin_master_func_names (func_name, name, state, sort_no) values ('gw_event', '週間・月間行事予定表', 'enabled', 10)"
    execute "insert into gw_section_admin_master_func_names (func_name, name, state, sort_no) values ('gw_props', 'レンタカー所属別実績一覧', 'enabled', 20)"
    execute "insert into gw_section_admin_master_func_names (func_name, name, state, sort_no) values ('gwsub_sb04', '電子事務分掌表', 'enabled', 30)"
  end

  def down
    execute "delete from gw_section_admin_master_func_names where func_name = 'gw_event'"
    execute "delete from gw_section_admin_master_func_names where func_name = 'gw_props'"
    execute "delete from gw_section_admin_master_func_names where func_name = 'gwsub_sb04'"
  end
end
