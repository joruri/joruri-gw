class CreateGwScheduleOptions < ActiveRecord::Migration
  def change
    create_table :gw_schedule_options do |t|
      t.column    :schedule_id , :integer
      t.column    :kind , :string, :limit => 50
      t.column    :body , :text
      t.timestamps
    end
  end
end
