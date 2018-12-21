class AddIndexToGwMemoUsers < ActiveRecord::Migration
  def change
    add_index :gw_memo_users, :schedule_id
  end
end
