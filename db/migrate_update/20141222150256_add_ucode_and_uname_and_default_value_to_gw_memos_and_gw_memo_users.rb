class AddUcodeAndUnameAndDefaultValueToGwMemosAndGwMemoUsers < ActiveRecord::Migration
  def change
    change_column :gw_memos, :is_finished, :integer, default: 0
    add_column :gw_memos, :ucode, :string, after: :uid
    add_column :gw_memos, :uname, :string, after: :ucode
    add_column :gw_memo_users, :ucode, :string, after: :uid
    add_column :gw_memo_users, :uname, :string, after: :ucode
  end
end
