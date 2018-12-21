class CreateGwSchedulePropTemporaries < ActiveRecord::Migration
  def change
    create_table :gw_schedule_prop_temporaries do |t|
      t.string    :tmp_id
      t.string    :prop_type
      t.integer   :prop_id
      t.datetime  :st_at
      t.datetime  :ed_at
      t.datetime  :created_at
      t.text      :created_user
      t.text      :created_group
      t.datetime  :updated_at
      t.text      :updated_user
      t.text      :updated_group
      t.datetime  :deleted_at
      t.text      :deleted_user
      t.text      :deleted_group
      t.timestamps
    end
  end
end
