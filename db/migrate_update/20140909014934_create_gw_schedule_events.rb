class CreateGwScheduleEvents < ActiveRecord::Migration
  def change
    create_table :gw_schedule_events do |t|
      t.integer  :schedule_id
      t.integer  :gid
      t.integer  :parent_gid
      t.integer  :uid
      t.integer  :sort_id
      t.string  :title, :limit =>  255
      t.text     :event_word
      t.string   :place, :limit =>  255
      t.datetime :st_at
      t.datetime :ed_at
      t.integer  :event_week
      t.integer  :week_approval
      t.datetime :week_approved_at
      t.integer  :week_approval_uid
      t.integer  :week_approval_gid
      t.integer  :week_open
      t.datetime :week_opened_at
      t.integer  :week_open_uid
      t.integer  :week_open_gid
      t.integer  :event_month
      t.integer  :month_approval
      t.datetime :month_approved_at
      t.integer  :month_approval_uid
      t.integer  :month_approval_gid
      t.integer  :month_open
      t.datetime :month_opened_at
      t.integer  :month_open_uid
      t.integer  :month_open_gid
      t.integer  :allday
      t.timestamps
    end
  end
end
