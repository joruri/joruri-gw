class CreateGwMeetingAccessLogs < ActiveRecord::Migration
  def change
    create_table :gw_meeting_access_logs do |t|
      t.text  :ip_address
      t.timestamps
    end
  end
end
