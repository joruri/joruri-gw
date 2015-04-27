class AddIndexToSystemLdapTemporaries < ActiveRecord::Migration
  def change
    add_index :system_ldap_temporaries, :version
  end
end
