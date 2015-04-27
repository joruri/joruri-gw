class AddIndexToGwPropExtraPmMeetingroomActualsAndGwPropExtraPmRentcarActuals < ActiveRecord::Migration
  def change
    [:gw_prop_extra_pm_meetingroom_actuals, :gw_prop_extra_pm_rentcar_actuals].each do |table|
      add_index table, :schedule_id
      #add_index table, :schedule_prop_id
      add_index table, :car_id
      add_index table, :driver_user_id
      add_index table, :driver_group_id
    end
  end
end
