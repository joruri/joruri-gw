class InsertDefaultValuesIntoGwReminders < ActiveRecord::Migration
  def change
    execute("insert into gw_reminders (state, sort_no, title, name, css_name) values ('enabled', 10, 'TODO', 'todo', 'todo')")
    execute("insert into gw_reminders (state, sort_no, title, name, css_name) values ('enabled', 10, 'JoruriPlus+', 'plus_update', 'plus_update')")
    execute("insert into gw_reminders (state, sort_no, title, name, css_name) values ('enabled', 20, '連絡メモ', 'memo', 'memo')")
    execute("insert into gw_reminders (state, sort_no, title, name, css_name) values ('enabled', 30, '回覧版', 'circular', 'circular')")
    execute("insert into gw_reminders (state, sort_no, title, name, css_name) values ('enabled', 40, '照会回答', 'monitor', 'monitor')")
    execute("insert into gw_reminders (state, sort_no, title, name, css_name) values ('enabled', 50, 'ワークフロー', 'workflow', 'denshiKessai')")
  end
end
