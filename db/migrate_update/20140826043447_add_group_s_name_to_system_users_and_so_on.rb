class AddGroupSNameToSystemUsersAndSoOn < ActiveRecord::Migration
  def change
    add_column :system_users, :group_s_name, :text, :after => :name_en
    add_column :system_groups, :group_s_name, :text, :after => :name_en
    add_column :system_group_temporaries, :group_s_name, :text, :after => :name_en
    add_column :system_group_histories, :group_s_name, :text, :after => :name_en
    add_column :system_group_history_temporaries, :group_s_name, :text, :after => :name_en
    add_column :system_ldap_temporaries, :group_s_name, :text, :after => :name_en
  end
end
