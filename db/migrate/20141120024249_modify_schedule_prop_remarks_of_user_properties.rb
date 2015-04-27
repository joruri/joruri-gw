class ModifySchedulePropRemarksOfUserProperties < ActiveRecord::Migration
  def up
    Gw::UserProperty.where(class_id: 3, name: "schedule_prop_meetingroom_remarks").delete_all
    Gw::UserProperty.where(class_id: 3, name: "schedule_prop_rentcar_remarks").delete_all
  end
  def down
  end
end
