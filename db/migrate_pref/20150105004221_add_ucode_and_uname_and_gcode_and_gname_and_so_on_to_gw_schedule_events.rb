class AddUcodeAndUnameAndGcodeAndGnameAndSoOnToGwScheduleEvents < ActiveRecord::Migration
  def change
    add_column :gw_schedule_events, :ucode, :string, after: :uid
    add_column :gw_schedule_events, :uname, :string, after: :ucode
    add_column :gw_schedule_events, :gcode, :string, after: :gid
    add_column :gw_schedule_events, :gname, :string, after: :gcode
    add_column :gw_schedule_events, :parent_gcode, :string, after: :parent_gid
    add_column :gw_schedule_events, :parent_gname, :string, after: :parent_gcode
    add_column :gw_schedule_events, :week_approval_ucode, :string, after: :week_approval_uid
    add_column :gw_schedule_events, :week_approval_uname, :string, after: :week_approval_ucode
    add_column :gw_schedule_events, :week_approval_gcode, :string, after: :week_approval_gid
    add_column :gw_schedule_events, :week_approval_gname, :string, after: :week_approval_gcode
    add_column :gw_schedule_events, :week_open_ucode, :string, after: :week_open_uid
    add_column :gw_schedule_events, :week_open_uname, :string, after: :week_open_ucode
    add_column :gw_schedule_events, :week_open_gcode, :string, after: :week_open_gid
    add_column :gw_schedule_events, :week_open_gname, :string, after: :week_open_gcode
    add_column :gw_schedule_events, :month_approval_ucode, :string, after: :month_approval_uid
    add_column :gw_schedule_events, :month_approval_uname, :string, after: :month_approval_ucode
    add_column :gw_schedule_events, :month_approval_gcode, :string, after: :month_approval_gid
    add_column :gw_schedule_events, :month_approval_gname, :string, after: :month_approval_gcode
    add_column :gw_schedule_events, :month_open_ucode, :string, after: :month_open_uid
    add_column :gw_schedule_events, :month_open_uname, :string, after: :month_open_ucode
    add_column :gw_schedule_events, :month_open_gcode, :string, after: :month_open_gid
    add_column :gw_schedule_events, :month_open_gname, :string, after: :month_open_gcode
  end
end
