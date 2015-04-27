class InsertGwsubSb05RoleIntoSystemRoles < ActiveRecord::Migration
  def change
    System::RoleName.where(:table_name=>"sb05").first_or_create(:display_name=>"広報依頼", :sort_no => 550)
    role_item   = System::RoleName.where(:table_name=>"sb05").first
    admin_priv  = System::PrivName.where(:priv_name => "admin").first
    System::RoleNamePriv.where(:role_id=>role_item.id,:priv_id=>admin_priv.id).first_or_create
  end
end
