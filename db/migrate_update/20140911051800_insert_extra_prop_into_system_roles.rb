class InsertExtraPropIntoSystemRoles < ActiveRecord::Migration
  def change
    System::RoleName.where(:table_name=>"gw_props").first_or_create(:display_name=>"管財課施設予約", :sort_no => 30)
    role_item   = System::RoleName.where(:table_name=>"gw_props").first
    System::PrivName.where(:priv_name => "pm").first_or_create(:display_name=>"管財課施設管理者", :sort_no => 4)
    admin_priv  = System::PrivName.where(:priv_name=>"pm").first
    System::RoleNamePriv.where(:role_id=>role_item.id,:priv_id=>admin_priv.id).first_or_create
  end
end
