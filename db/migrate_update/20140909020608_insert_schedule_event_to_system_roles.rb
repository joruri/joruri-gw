class InsertScheduleEventToSystemRoles < ActiveRecord::Migration
  def change
    System::RoleName.where(:table_name=>"gw_event").first_or_create(:display_name=>"週間・月間行事予定表", :sort_no => 70)
    role_item   = System::RoleName.where(:table_name=>"gw_event").first
    admin_priv  = System::PrivName.where(:priv_name => "admin").first
    csv_put_user_priv = System::PrivName.where(:priv_name => "csv_put_user").first
    System::RoleNamePriv.where(:role_id=>role_item.id,:priv_id=>admin_priv.id).first_or_create
    System::RoleNamePriv.where(:role_id=>role_item.id,:priv_id=>csv_put_user_priv.id).first_or_create
  end
end
