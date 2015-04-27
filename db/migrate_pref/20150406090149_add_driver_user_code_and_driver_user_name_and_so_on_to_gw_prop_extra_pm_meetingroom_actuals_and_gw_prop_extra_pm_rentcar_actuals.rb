class AddDriverUserCodeAndDriverUserNameAndSoOnToGwPropExtraPmMeetingroomActualsAndGwPropExtraPmRentcarActuals < ActiveRecord::Migration
  def change
    [:gw_prop_extra_pm_meetingroom_actuals, :gw_prop_extra_pm_rentcar_actuals].each do |table|
      add_column table, :driver_user_code, :string, after: :driver_user_id
      add_column table, :driver_user_name, :string, after: :driver_user_code
      add_column table, :driver_group_code, :string, after: :driver_group_id
      add_column table, :driver_group_name, :string, after: :driver_group_code
    end
  end
end
