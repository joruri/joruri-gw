# encoding: utf-8
## users role
puts "Import user auth settings"

def create_priv_name(display_name,priv_name,sort_no)
  System::PrivName.create({
    display_name: display_name, priv_name: priv_name, sort_no:sort_no, state: 'public'
  })
end

def create_role_name(display_name,table_name,sort_no)
  System::RoleName.create({
    display_name: display_name, table_name: table_name, sort_no:sort_no
  })
end

def create_role_name_priv(role_id,priv_id)
  System::RoleNamePriv.create({
    role_id: role_id, priv_id: priv_id
  })
end

def create_admin_role(role, priv)
  System::Role.create({
    table_name: role.table_name, priv_name: priv.priv_name,
    idx: 1, priv: 1,class_id: 1, uid: 1, group_id: 3,
    role_name_id: role.id, priv_user_id: priv.id
  })
end

admin = create_priv_name('管理者', 'admin',  0)
schedule_pref_admin = create_priv_name('全庁予定登録者', 'schedule_pref_admin',  2)
csv_put_user = create_priv_name('CSV出力', 'csv_put_user',   20)
editor = create_priv_name('編集者', 'editor',   30)
recognizer = create_priv_name('承認者', 'recognizer', 40)
pm = create_priv_name('管財課施設管理者', 'pm', 4)

_admin = create_role_name('GW管理画面', '_admin', 1)
create_role_name_priv(_admin.id, admin.id)
create_admin_role(_admin, admin)

schedule_pref = create_role_name('全庁予定登録', 'schedule_pref', 11)
create_role_name_priv(schedule_pref.id, schedule_pref_admin.id)

gw_props = create_role_name('管財課施設予約', 'gw_props', 30)
create_role_name_priv(gw_props.id, pm.id)

gw_event = create_role_name('週間・月間行事予定表', 'gw_event', 70)
create_role_name_priv(gw_event.id, admin.id)
create_role_name_priv(gw_event.id, csv_put_user.id)
create_admin_role(gw_event, admin)

digitallibrary = create_role_name('電子図書', 'digitallibrary', 140)
create_role_name_priv(digitallibrary.id, admin.id)
create_admin_role(digitallibrary, admin)

doclibrary = create_role_name('書庫', 'doclibrary', 130)
create_role_name_priv(doclibrary.id, admin.id)
create_admin_role(doclibrary, admin)

gwbbs = create_role_name('掲示板', 'gwbbs', 110)
create_role_name_priv(gwbbs.id, admin.id)
create_admin_role(gwbbs, admin)

gwfaq = create_role_name('質問管理（FAQ形式）', 'gwfaq', 120)
create_role_name_priv(gwfaq.id, admin.id)
create_admin_role(gwfaq, admin)

gwqa = create_role_name('質問管理（QA形式）', 'gwqa', 121)
create_role_name_priv(gwqa.id, admin.id)
create_admin_role(gwqa, admin)

system_users = create_role_name('システムユーザー管理', 'system_users', 910)
create_role_name_priv(system_users.id, admin.id)

edit_tab = create_role_name('タブ編集', 'edit_tab', 930)
create_role_name_priv(edit_tab.id, admin.id)
create_admin_role(edit_tab, admin)

gwcircular = create_role_name('回覧板', 'gwcircular', 105)
create_role_name_priv(gwcircular.id, admin.id)
create_admin_role(gwcircular, admin)

gwmonitor = create_role_name('照会・回答システム', 'gwmonitor', 107)
create_role_name_priv(gwmonitor.id, admin.id)
create_admin_role(gwmonitor, admin)

enquete = create_role_name('アンケート', 'enquete', 108)
create_role_name_priv(enquete.id, admin.id)
create_admin_role(enquete, admin)

gw_pref_assembly = create_role_name('議員表示管理', 'gw_pref_assembly', 940)
create_role_name_priv(gw_pref_assembly.id, admin.id)
create_admin_role(gw_pref_assembly, admin)

gw_pref_executive = create_role_name('県幹部在庁表示', 'gw_pref_executive', 950)
create_role_name_priv(gw_pref_executive.id, admin.id)
create_admin_role(gw_pref_executive, admin)

gw_pref_director = create_role_name('部課長在庁表示　管理者', 'gw_pref_director', 960)
create_role_name_priv(gw_pref_director.id, admin.id)
create_admin_role(gw_pref_director, admin)

sb01 = create_role_name('研修申込・受付', 'sb01', 510)
create_role_name_priv(sb01.id, admin.id)
create_admin_role(sb01, admin)

sb04 = create_role_name('職員名簿', 'sb04', 540)
create_role_name_priv(sb04.id, admin.id)
create_admin_role(sb04, admin)

meeting_guide = create_role_name('会議開催案内', 'meeting_guide', 970)
create_role_name_priv(meeting_guide.id, admin.id)
create_admin_role(meeting_guide, admin)

sb12 = create_role_name('媒体管理', 'sb12', 620)
create_role_name_priv(sb12.id, admin.id)
create_admin_role(sb12, admin)

sb05 = create_role_name('広報依頼', 'sb05', 550)
create_role_name_priv(sb05.id, admin.id)
create_admin_role(sb05, admin)

sb0601 = create_role_name('予算担当管理', 'sb0601', 560)
create_role_name_priv(sb0601.id, admin.id)
create_admin_role(sb0601, admin)

sb0602 = create_role_name('担当者名等管理', 'sb0602', 565)
create_role_name_priv(sb0602.id, admin.id)
create_admin_role(sb0602, admin)

