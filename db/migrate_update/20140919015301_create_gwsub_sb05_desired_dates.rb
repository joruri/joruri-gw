class CreateGwsubSb05DesiredDates < ActiveRecord::Migration
  def change
    create_table :gwsub_sb05_desired_dates do |t|
      t.integer :media_id
      t.datetime   :desired_at
      t.datetime   :updated_at
      t.text   :updated_user
      t.text   :updated_group
      t.datetime   :created_at
      t.text    :created_user
      t.text    :created_group
      t.text    :media_code
      t.text    :weekday
      t.text    :monthly
      t.datetime   :edit_limit_at
      t.timestamps
    end
  end
end
