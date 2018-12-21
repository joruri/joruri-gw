#20140901092929
class InsertIntoSystemRoles < ActiveRecord::Migration
  def change
    System::RoleName.where(:table_name=>"meeting_guide").first_or_create(:display_name=>"会議開催案内", :sort_no => 970)
    role_item   = System::RoleName.where(:table_name=>"meeting_guide").first
    admin_priv  = System::PrivName.where(:priv_name => "admin").first
    editor_priv = System::PrivName.where(:priv_name => "editor").first
    System::RoleNamePriv.where(:role_id=>role_item.id,:priv_id=>admin_priv.id).first_or_create
    System::RoleNamePriv.where(:role_id=>role_item.id,:priv_id=>editor_priv.id).first_or_create
  end
end
