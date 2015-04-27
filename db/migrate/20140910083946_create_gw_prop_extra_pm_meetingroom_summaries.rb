class CreateGwPropExtraPmMeetingroomSummaries < ActiveRecord::Migration
  def change
    create_table :gw_prop_extra_pm_meetingroom_summaries do |t|
      t.datetime :summaries_at
      t.integer :group_id
      t.integer :run_meter
      t.integer :bill_amount
      t.text :bill_state
      t.text :updated_user
      t.text :updated_group
      t.text :created_user
      t.text :created_group
      t.timestamps
    end
  end
end
