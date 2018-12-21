class InsertGwsubSb06RoleIntoSystemRoles < ActiveRecord::Migration
  def change
    admin_priv  = System::PrivName.where(:priv_name => "admin").first
    #予算担当管理
    System::RoleName.where(:table_name=>"sb0601").first_or_create(:display_name=>"予算担当管理", :sort_no => 560)
    role_item   = System::RoleName.where(:table_name=>"sb0601").first
    System::RoleNamePriv.where(:role_id=>role_item.id,:priv_id=>admin_priv.id).first_or_create

    #担当者名等管理
    System::RoleName.where(:table_name=>"sb0602").first_or_create(:display_name=>"担当者名等管理", :sort_no => 565)
    role_item   = System::RoleName.where(:table_name=>"sb0602").first
    System::RoleNamePriv.where(:role_id=>role_item.id,:priv_id=>admin_priv.id).first_or_create
  end
end
