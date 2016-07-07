class DropObsoleteTables < ActiveRecord::Migration
  def up
    drop_table :system_admin_logs
    drop_table :system_authorizations
    drop_table :system_commitments
    drop_table :system_creators
    drop_table :system_group_change_pickups
    drop_table :system_group_changes
    drop_table :system_group_versions
    drop_table :system_idconversions
    drop_table :system_inquiries
    drop_table :system_languages
    drop_table :system_maps
    drop_table :system_public_logs
    drop_table :system_publishers
    drop_table :system_tags
    drop_table :system_tasks
    drop_table :system_unids
  end
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
