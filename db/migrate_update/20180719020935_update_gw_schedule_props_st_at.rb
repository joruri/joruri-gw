class UpdateGwSchedulePropsStAt < ActiveRecord::Migration
  def change
    execute("update gw_schedule_props set st_at = (select st_at from gw_schedules where id = schedule_id), ed_at = (select ed_at from gw_schedules where id = schedule_id)")
  end
end
