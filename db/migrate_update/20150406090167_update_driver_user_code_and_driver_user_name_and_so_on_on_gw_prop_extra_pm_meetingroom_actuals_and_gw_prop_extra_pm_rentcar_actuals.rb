class UpdateDriverUserCodeAndDriverUserNameAndSoOnOnGwPropExtraPmMeetingroomActualsAndGwPropExtraPmRentcarActuals < ActiveRecord::Migration
  def change
    [:gw_prop_extra_pm_meetingroom_actuals, :gw_prop_extra_pm_rentcar_actuals].each do |table|
      execute "update #{table} set driver_user_code = (select code from system_users where id = driver_user_id)"
      execute "update #{table} set driver_user_name = (select name from system_users where id = driver_user_id)"
      execute "update #{table} set driver_group_code = (select code from system_group_histories where id = driver_group_id)"
      execute "update #{table} set driver_group_name = (select name from system_group_histories where id = driver_group_id)"
    end
  end
end
