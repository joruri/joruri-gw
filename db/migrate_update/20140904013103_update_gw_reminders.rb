class UpdateGwReminders < ActiveRecord::Migration
  def change
    Gw::Reminder.where(:name => "todo").update_all(:name => "schedule_todo")
  end
end
