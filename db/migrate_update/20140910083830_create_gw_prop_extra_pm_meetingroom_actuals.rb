class CreateGwPropExtraPmMeetingroomActuals < ActiveRecord::Migration
  def change
    create_table :gw_prop_extra_pm_meetingroom_actuals do |t|
      t.integer :schedule_id
      t.integer :schedule_prop_id
      t.integer :car_id
      t.integer :driver_user_id
      t.integer :driver_group_id
      t.datetime :start_at
      t.datetime :end_at
      t.integer :start_meter
      t.integer :end_meter
      t.integer :run_meter
      t.text :summaries_state
      t.text :bill_state
      t.integer :toll_fee
      t.integer :refuel_amount
      t.text :to_go
      t.text :title
      t.text :updated_user
      t.text :updated_group
      t.text :created_user
      t.text :created_group
      t.timestamps
    end
  end
end
