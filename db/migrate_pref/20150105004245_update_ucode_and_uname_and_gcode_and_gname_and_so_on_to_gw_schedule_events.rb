class UpdateUcodeAndUnameAndGcodeAndGnameAndSoOnToGwScheduleEvents < ActiveRecord::Migration
  def up
    execute "update gw_schedule_events set ucode = (select code from system_users where id = uid)"
    execute "update gw_schedule_events set uname = (select name from system_users where id = uid)"
    execute "update gw_schedule_events set gcode = (select code from system_group_histories where id = gid)"
    execute "update gw_schedule_events set gname = (select name from system_group_histories where id = gid)"
    execute "update gw_schedule_events set parent_gcode = (select code from system_group_histories where id = parent_gid)"
    execute "update gw_schedule_events set parent_gname = (select name from system_group_histories where id = parent_gid)"
    execute "update gw_schedule_events set week_approval_ucode = (select code from system_users where id = week_approval_uid)"
    execute "update gw_schedule_events set week_approval_uname = (select name from system_users where id = week_approval_uid)"
    execute "update gw_schedule_events set week_approval_gcode = (select code from system_group_histories where id = week_approval_gid)"
    execute "update gw_schedule_events set week_approval_gname = (select name from system_group_histories where id = week_approval_gid)"
    execute "update gw_schedule_events set week_open_ucode = (select code from system_users where id = week_open_uid)"
    execute "update gw_schedule_events set week_open_uname = (select name from system_users where id = week_open_uid)"
    execute "update gw_schedule_events set week_open_gcode = (select code from system_group_histories where id = week_open_gid)"
    execute "update gw_schedule_events set week_open_gname = (select name from system_group_histories where id = week_open_gid)"
    execute "update gw_schedule_events set month_approval_ucode = (select code from system_users where id = month_approval_uid)"
    execute "update gw_schedule_events set month_approval_uname = (select name from system_users where id = month_approval_uid)"
    execute "update gw_schedule_events set month_approval_gcode = (select code from system_group_histories where id = month_approval_gid)"
    execute "update gw_schedule_events set month_approval_gname = (select name from system_group_histories where id = month_approval_gid)"
    execute "update gw_schedule_events set month_open_ucode = (select code from system_users where id = month_open_uid)"
    execute "update gw_schedule_events set month_open_uname = (select name from system_users where id = month_open_uid)"
    execute "update gw_schedule_events set month_open_gcode = (select code from system_group_histories where id = month_open_gid)"
    execute "update gw_schedule_events set month_open_gname = (select name from system_group_histories where id = month_open_gid)"
  end
  def down
  end
end
