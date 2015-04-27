class InsertPropRemarksIntoGwUserProperty < ActiveRecord::Migration
  def change
    Gw::UserProperty.where(:class_id => 3, :name => "schedule_prop_meetingroom_remarks", :type_name => "10").first_or_create(:options=>"注意事項,#")
    Gw::UserProperty.where(:class_id => 3, :name => "schedule_prop_rentcar_remarks", :type_name => "20").first_or_create(:options=>"注意事項,#")
  end
end
