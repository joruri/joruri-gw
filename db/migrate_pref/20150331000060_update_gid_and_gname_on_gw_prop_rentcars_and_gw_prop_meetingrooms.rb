class UpdateGidAndGnameOnGwPropRentcarsAndGwPropMeetingrooms < ActiveRecord::Migration
  def change
    execute "update gw_prop_rentcars set gid = 706,gname = '管財課'"
    execute "update gw_prop_meetingrooms set gid = 706, gname = '管財課'"
  end
end
