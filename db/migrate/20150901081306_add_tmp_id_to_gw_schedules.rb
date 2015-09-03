class AddTmpIdToGwSchedules < ActiveRecord::Migration
  def change
    add_column :gw_schedules , :tmp_id, :string
  end
end
