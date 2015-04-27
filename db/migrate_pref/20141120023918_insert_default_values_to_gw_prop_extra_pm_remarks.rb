class InsertDefaultValuesToGwPropExtraPmRemarks < ActiveRecord::Migration
  def up
    #会議室
    execute %|insert into gw_prop_extra_pm_remarks (prop_class_id, state, sort_no, title, url) values (1, 'enabled', 10, '連絡事項', '/gwbbs/docs/2?title_id=38');|
    execute %|insert into gw_prop_extra_pm_remarks (prop_class_id, state, sort_no, title, url) values (1, 'enabled', 20, '注意事項', '/gwbbs/docs/3?title_id=38');|
    execute %|insert into gw_prop_extra_pm_remarks (prop_class_id, state, sort_no, title, url) values (1, 'enabled', 30, 'ヘルプ', '/gwbbs/docs?title_id=38');|
    execute %|insert into gw_prop_extra_pm_remarks (prop_class_id, state, sort_no, title, url) values (1, 'enabled', 30, '<div style="color:red; display:inline;">必ず注意事項をご覧ください。</div>', '/gwbbs/docs/3?title_id=38');|
    #レンタカー
    execute %|insert into gw_prop_extra_pm_remarks (prop_class_id, state, sort_no, title, url) values (2, 'enabled', 10, '鍵の受け渡し', '/gwbbs/docs/5?title_id=58');|
    execute %|insert into gw_prop_extra_pm_remarks (prop_class_id, state, sort_no, title, url) values (2, 'enabled', 20, '予約の入力', '/gwbbs/docs/6?title_id=58');|
    execute %|insert into gw_prop_extra_pm_remarks (prop_class_id, state, sort_no, title, url) values (2, 'enabled', 30, '運転使用報告書', '/gwbbs/docs/16?title_id=58');|
    execute %|insert into gw_prop_extra_pm_remarks (prop_class_id, state, sort_no, title, url) values (2, 'enabled', 40, 'ヘルプ', '/gwbbs/docs/?title_id=58');|
    execute %|insert into gw_prop_extra_pm_remarks (prop_class_id, state, sort_no, title, url) values (2, 'enabled', 50, '<div style="color:red; display:inline;">必ず注意事項をご覧ください。</div>', '/gwbbs/docs/17?title_id=58');|
  end
  def down
  end
end
