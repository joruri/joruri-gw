class UpdateUcodeAndUnameOnGwMemosAndGwMemoUsers < ActiveRecord::Migration
  def up
    execute "update gw_memos set is_finished = 0 where is_finished is null"
    execute "update gw_memos set ucode = (select code from system_users where id = uid)"
    execute "update gw_memos set uname = (select name from system_users where id = uid)"
    execute "update gw_memo_users set ucode = (select code from system_users where id = uid)"
    execute "update gw_memo_users set uname = (select name from system_users where id = uid)"
  end
  def down
  end
end
