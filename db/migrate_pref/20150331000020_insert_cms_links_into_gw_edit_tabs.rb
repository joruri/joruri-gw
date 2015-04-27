class InsertCmsLinksIntoGwEditTabs < ActiveRecord::Migration
  def change
    cms_url = Joruri.config.application['migrate.cms_url']
    execute <<-SQL
      insert into gw_edit_tabs (class_created, published, state, level_no, parent_id, name, sort_no, tab_keys, other_controller_use, link_url, class_external, class_sso, field_account, field_pass, is_public) 
        values (1, 'closed', 'enabled', 2, 1, 'Joruri CMS', 150, 0, 3, '#{cms_url}', 1, 2, 'account', 'password', 0)
    SQL
  end
end
