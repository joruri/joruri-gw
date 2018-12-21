class InsertDefaultValuesIntoGwmonitorForms < ActiveRecord::Migration
  def up
    execute "update gwmonitor_forms set form_caption = 'テキスト形式' where form_name = 'form001'"
    execute "insert into gwmonitor_forms (sort_no, level_no, form_name, form_caption) values (10, 10, 'form002', '複数行形式')"
  end

  def down
    execute "delete from gwmonitor_forms where form_name = 'form002'"
  end
end
