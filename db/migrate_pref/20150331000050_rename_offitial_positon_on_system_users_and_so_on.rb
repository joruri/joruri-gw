class RenameOffitialPositonOnSystemUsersAndSoOn < ActiveRecord::Migration
  def change
    rename_column :system_users, :offitial_position, :official_position
    rename_column :system_ldap_temporaries, :offitial_position, :official_position
    rename_column :system_user_temporaries, :offitial_position, :official_position
  end
end
