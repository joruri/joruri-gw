# encoding: utf-8
##link piece and edit tabs
puts "Import link menu settings"

def create_link_piece_csses(css_name, sort_no, css_class, css_type)
  Gw::EditLinkPieceCss.create({
    state: 'enabled', css_name: css_name, css_sort_no: sort_no,
    css_class: css_class, css_type: css_type
  })
end

create_link_piece_csses '総務事務システム',   10,  'soumu', 2
create_link_piece_csses '電子決済・文書管理', 20,  'denshiKessai',  2
create_link_piece_csses '職員名簿',  30,  'directory', 2
create_link_piece_csses '掲示板',    40,  'bbs',       2
create_link_piece_csses '施設予約',  50,  'props',     2
create_link_piece_csses '質問管理',  60,  'qa',        2
create_link_piece_csses 'リンク',      70,  'fq',        2
create_link_piece_csses '繰返し１件目',     10,  'head2',  1
create_link_piece_csses '繰返し２件目以降',  20,  'head',   1
create_link_piece_csses '電子図書，マニュアル', 80,  'ebook',  2
create_link_piece_csses '書庫',          90,  'library',  2
create_link_piece_csses 'メーラー',        100, 'menu_mailer',     1
create_link_piece_csses 'スケジュール ',     110, 'menu_schedules',  1
create_link_piece_csses 'Todo',         120, 'menu_todo',   1
create_link_piece_csses '連絡メモ',        130, 'menu_memo',   1
create_link_piece_csses '新規作成',       140, 'menu_new',    1
create_link_piece_csses '照会・回答システム', 150, 'monitor',     2
create_link_piece_csses 'DECO',       160, 'menuDeco',      1
create_link_piece_csses 'DECOクラウド版', 170, 'menuDecoCloud', 1
create_link_piece_csses 'DECO県版',    180, 'menuDecoPref',  1

def create_link_piece(level_no,parent_id,name,sort_no,tab_keys,display_auth_priv,role_name_id,display_auth,block_icon_id,block_css_id,link_url,icon_path,class_external,class_sso,field_account,field_pass)
  Gw::EditLinkPiece.create({
    class_created: 1, published: 'opened', state: 'enabled', mode: 1,css_id: 0,
    level_no: level_no, parent_id: parent_id, name: name, sort_no: sort_no,
    tab_keys: tab_keys, display_auth_priv: display_auth_priv,
    role_name_id: role_name_id, display_auth: display_auth,
    block_icon_id: block_icon_id, block_css_id: block_css_id,
    link_url: link_url, icon_path: icon_path, class_external: class_external,
    class_sso: class_sso, field_account: field_account, field_pass: field_pass
   })
end

top_piece = create_link_piece(1,nil,"TOP",10,0,1,nil,nil,nil,nil,nil,nil,1,1,nil,nil)
left_piece = create_link_piece(2,top_piece.id,"ポータル左　リンクピース",10,10,1,nil,nil,nil,nil,nil,nil,1,1,nil,nil)
head_piece = create_link_piece(2,top_piece.id,"ポータルヘッダ　アイコンメニュー",30,30,1,nil,nil,nil,nil,nil,nil,1,1,nil,nil)

left_bbs = create_link_piece(3,left_piece.id,"掲示板",70,0,1,nil,nil,4,9,"/gwbbs",nil,1,1,nil,nil)
create_link_piece(4,left_bbs.id,"全庁掲示板",10,0,nil,nil,nil,nil,nil,"/gwbbs/docs?title_id=1&limit=10",nil,1,1,nil,nil)

prop = create_link_piece(3,left_piece.id,"施設予約",80,0,1,nil,nil,5,9,"/gw/schedule_props/show_week?s_genre=other&cls=other&type_id=200",nil,1,1,nil,nil)
create_link_piece(4,prop.id,"公用車予約",10,0,nil,nil,nil,nil,nil,"/gw/schedule_props/show_week?s_genre=other&cls=other&type_id=100",nil,1,1,nil,nil)
create_link_piece(4,prop.id,"会議室予約",20,0,nil,nil,nil,nil,nil,"/gw/schedule_props/show_week?s_genre=other&cls=other&type_id=200",nil,1,1,nil,nil)
create_link_piece(4,prop.id,"一般備品",30,0,nil,nil,nil,nil,nil,"/gw/schedule_props/show_week?s_genre=other&cls=other&type_id=300",nil,1,1,nil,nil)

create_link_piece(3,left_piece.id,"質問管理",90,0,1,nil,nil,6,9,"/gwfaq",nil,1,1,nil,nil)

link = create_link_piece(3,left_piece.id,"リンク",100,0,1,nil,nil,7,9,nil,nil,1,1,nil,nil)
create_link_piece(4,link.id,"Joruri公式サイト",10,0,nil,nil,nil,nil,nil,"http://joruri.org/",nil,2,1,nil,nil)

portal = create_link_piece(3,head_piece.id,"ポータル",10,0,1,nil,nil,nil,nil,"/",nil,1,1,nil,nil)
create_link_piece(4,portal.id,"ポータル",10,0,1,nil,nil,nil,nil,"/","/_common/themes/gw/files/menu/ic_home.gif",1,1,nil,nil)


mail_product = System::Product.create({
  name: "JoruriMail",
  product_type: "mail",
  sort_no: 10,
  product_synchro: 1,
  sso: 1,
  sso_url: "http://demo.webmail.joruri.org/_admin/air_sso",
  sso_url_mobile: "http://demo.webmail.joruri.org/_admin/air_sso"
})

mail = create_link_piece(3,head_piece.id,"メール",20,0,1,nil,nil,nil,12,"",nil,2,mail_product.product_type,"account","password")
create_link_piece(4,mail.id,"メール",10,0,1,nil,nil,nil,nil,"","/_common/themes/gw/files/menu/ic_mailer.gif",2,mail_product.product_type,"account","password")

schedule = create_link_piece(3,head_piece.id,"スケジュール",40,0,1,nil,nil,nil,13,"/gw/schedules/show_month",nil,1,1,nil,nil)
create_link_piece(4,schedule.id,"スケジュール",10,0,1,nil,nil,nil,nil,"/gw/schedules/show_month","/_common/themes/gw/files/menu/ic_schedule.gif",1,1,nil,nil)
create_link_piece(4,schedule.id,"新規作成",20,0,1,nil,nil,nil,16,"/gw/schedules/new","/_common/themes/gw/files/schedule/ic_add.gif",1,1,nil,nil)

todo = create_link_piece(3,head_piece.id,"ToDo",50,0,1,nil,nil,nil,14,"/gw/schedule_todos",nil,1,1,nil,nil)
create_link_piece(4,todo.id,"ToDo",10,0,1,nil,nil,nil,nil,"/gw/schedule_todos","/_common/themes/gw/files/menu/ic_todo.gif",1,1,nil,nil)
create_link_piece(4,todo.id,"新規作成",20,0,1,nil,nil,nil,16,"/gw/schedules/new?link=todo","/_common/themes/gw/files/schedule/ic_add.gif",1,1,nil,nil)

memo = create_link_piece(3,head_piece.id,"連絡メモ",60,0,1,nil,nil,nil,15,"/gw/memos",nil,1,1,nil,nil)
create_link_piece(4,memo.id,"連絡メモ",10,0,1,nil,nil,nil,nil,"/gw/memos","/_common/themes/gw/files/menu/ic_memo.gif",1,1,nil,nil)
create_link_piece(4,memo.id,"新規作成",20,0,1,nil,nil,nil,16,"/gw/memos/new","/_common/themes/gw/files/schedule/ic_add.gif",1,1,nil,nil)

bbs = create_link_piece(3,head_piece.id,"掲示板",90,0,1,nil,nil,nil,nil,"/gwbbs",nil,1,1,nil,nil)
create_link_piece(4,bbs.id,"掲示板",10,0,1,nil,nil,nil,nil,"/gwbbs","/_common/themes/gw/files/menu/ic_board.gif",1,1,nil,nil)

faq = create_link_piece(3,head_piece.id,"質問管理",100,0,1,nil,nil,nil,nil,"/gwfaq",nil,1,1,nil,nil)
create_link_piece(4,faq.id,"質問管理",10,0,1,nil,nil,nil,nil,"/gwfaq","/_common/themes/gw/files/menu/ic_qa-admin.gif",1,1,nil,nil)

doclibrary = create_link_piece(3,head_piece.id,"書庫",110,0,1,nil,nil,nil,nil,"/doclibrary",nil,1,1,nil,nil)
create_link_piece(4,doclibrary.id,"書庫",10,0,1,nil,nil,nil,nil,"/doclibrary","/_common/themes/gw/files/menu/ic_library.gif",1,1,nil,nil)

digitallibrary = create_link_piece(3,head_piece.id,"電子図書",120,0,1,nil,nil,nil,nil,"/digitallibrary","/digitallibrary",1,1,nil,nil)
create_link_piece(4,digitallibrary.id,"電子図書",10,0,1,nil,nil,nil,nil,"/digitallibrary","/_common/themes/gw/files/menu/ic_electronic-book.gif",1,1,nil,nil)

config = create_link_piece(3,head_piece.id,"設定",130,0,0,21,nil,nil,nil,"/gw/config_settings",nil,1,1,nil,nil)
create_link_piece(4,config.id ,"設定",10,0,1,nil,nil,nil,nil,"/gw/config_settings","/_common/themes/gw/files/menu/ic_system.gif",1,1,nil,nil)

deco = create_link_piece(3,head_piece.id,"DECO Drive",140,0,1,nil,nil,nil,18,"http://drive.deco-project.org/",nil,2,1,nil,nil)
create_link_piece(4,deco.id,"DECO Drive",10,0,1,nil,nil,nil,nil,"http://drive.deco-project.org/","/_common/themes/gw/files/menu/ic_deco.gif",2,1,nil,nil)

circular = create_link_piece(3,head_piece.id,"回覧板",70,0,1,nil,nil,nil,15,"/gwcircular",nil,1,1,nil,nil)
create_link_piece(4,circular.id,"回覧板",10,0,1,nil,nil,nil,nil,"/gwcircular","/_common/themes/gw/files/menu/ic_circulation.gif",1,1,nil,nil)
create_link_piece(4,circular.id,"新規作成",20,0,nil,nil,nil,nil,16,"/gwcircular/new","/_common/themes/gw/files/schedule/ic_add.gif",1,1,nil,nil)

monitor = create_link_piece(3,head_piece.id,"照会・回答",80,0,nil,nil,nil,nil,15,"/gwmonitor",nil,1,1,nil,nil)
create_link_piece(4,monitor.id,"照会・回答システム",10,0,nil,nil,nil,17,nil,"/gwmonitor","/_common/themes/gw/files/menu/ic_dennshisyoukai.gif",1,1,nil,nil)
create_link_piece(4,monitor.id,"新規作成",20,0,nil,nil,nil,nil,16,"/gwmonitor/builders/new","/_common/themes/gw/files/schedule/ic_add.gif",1,1,nil,nil)

left_monitor = create_link_piece(3,left_piece.id ,"照会・回答",60,0,nil,nil,nil,17,9,"/gwmonitor",nil,1,1,nil,nil)
create_link_piece(4,left_monitor.id,"照会・回答システム",10,0,nil,nil,nil,17,9,"/gwmonitor",nil,1,1,nil,nil)
create_link_piece(4,left_monitor.id,"アンケート集計システム",20,0,nil,nil,nil,nil,nil,"/enquete/",nil,1,1,nil,nil)
create_link_piece(4,left_monitor.id,"研修等申込・受付システム",30,0,nil,nil,nil,nil,nil,"/gwsub/sb01/sb01_training_entries",nil,1,1,nil,nil)

create_link_piece(3,left_piece.id,"総務事務システム",30,0,nil,nil,nil,1,8,"#",nil,1,1,nil,nil)

workflow = create_link_piece(3,left_piece.id,"電子決裁・文書管理",50,0,nil,nil,nil,2,9,"#",nil,1,1,nil,nil)
create_link_piece(4,workflow.id,"ワークフロー",10,0,nil,nil,nil,2,nil,"/gwworkflow",nil,1,1,nil,nil)

stafflist = create_link_piece(3,left_piece.id,"職員名簿",70,0,nil,nil,nil,3,9,nil,nil,1,1,nil,nil)
create_link_piece(4,stafflist.id,"電子職員録",10,0,nil,nil,nil,nil,nil,"/gwsub/sb04/01/sb04stafflistview",nil,1,1,nil,nil)
create_link_piece(4,stafflist.id,"電子事務分掌表",20,0,nil,nil,nil,nil,nil,"/gwsub/sb04/02/sb04divideduties",nil,1,1,nil,nil)

def create_tab(is_public,level_no,parent_id,name,sort_no,tab_keys,display_auth,other_controller_use,other_controller_url,link_url,icon_path,link_div_class,class_external,class_sso,field_account,field_pass)
  Gw::EditTab.create({
    class_created: 1, published: 'opened', state: 'enabled',
    level_no: level_no, parent_id: parent_id, name: name, sort_no: sort_no,css_id:0, is_public: is_public,
    tab_keys: tab_keys, display_auth: display_auth, other_controller_use: other_controller_use,
    other_controller_url: other_controller_url,
    link_url: link_url, icon_path: icon_path, link_div_class: link_div_class,
    class_external: class_external, class_sso: class_sso, field_account: field_account, field_pass: field_pass
   })
end


top_tab = create_tab(0,1,nil,"TOP",10,0,nil,2,nil,nil,nil,nil,1,1,nil,nil)

create_tab(0,2,top_tab.id,"ポータル",10,1,nil,1,"/",nil,nil,nil,1,1,nil,nil)

gwsub_tab = create_tab(0,2,top_tab.id,"個別業務",50,80,nil,2,nil,nil,nil,nil,1,1,nil,nil)

sub_system = create_tab(0,3,gwsub_tab.id,"個別システム",10,0,nil,2,nil,nil,nil,nil,1,1,nil,nil)

create_tab(0,4,sub_system.id,"アンケート集計システム",30,0,nil,2,nil,"/questionnaire/",nil,nil,1,1,nil,nil)
create_tab('2',4,sub_system.id,"議員表示　管理者用",40,0,"Gw::PrefAssemblyMember.editable?",2,nil,"/gw/pref_assembly_member_admins",nil,nil,1,1,nil,nil)
create_tab('2',4,sub_system.id,"全庁幹部在庁表示　管理者用",50,0,"Gw::PrefExecutive.is_admin?",2,nil,"/gw/pref_executive_admins",nil,nil,1,1,nil,nil)
create_tab('2',4,sub_system.id,"部課長在庁表示　管理者用",60,0,"Gw::PrefDirector.is_admin?",2,nil,"/gw/pref_director_admins",nil,nil,1,1,nil,nil)
create_tab(0,4,sub_system.id,"電子職員録",70,0,nil,2,nil,"/gwsub/sb04/01/sb04stafflistview",nil,nil,1,1,nil,nil)
create_tab(0,4,sub_system.id,"研修等申込・受付システム",80,0,nil,2,nil,"/gwsub/sb01/sb01_training_entries",nil,nil,1,1,nil,nil)
create_tab(0,4,sub_system.id,"担当者名等管理",90,0,nil,2,nil,"/gwsub/sb06/sb06_assigned_conferences",nil,nil,0,1,nil,nil)
create_tab(0,4,sub_system.id,"予算担当登録",100,0,nil,2,nil,"/gwsub/sb06/sb06_budget_notices?v=2",nil,nil,0,1,nil,nil)
create_tab(0,4,sub_system.id,"広報依頼システム",110,0,nil,2,nil,"/gwsub/sb05/sb05_requests",nil,nil,0,1,nil,nil)
create_tab(0,4,sub_system.id,"週間・月間行事予定表（承認・公開）",120,0,nil,2,nil,"/gw/schedule_events/",nil,nil,0,1,nil,nil)
create_tab(0,4,sub_system.id,"USBメモリ登録管理台帳",130,0,nil,2,nil,"/gwsub/sb12/externalusbs/",nil,nil,0,1,nil,nil)
create_tab(0,4,sub_system.id,"その他の外部記録媒体登録管理台帳",140,0,nil,2,nil,"/gwsub/sb13/externalmedias/",nil,nil,0,1,nil,nil)

link_tab = create_tab(0,2,top_tab.id,"便利リンク",60,3,nil,2,nil,nil,nil,nil,0,1,nil,nil)
create_tab(0,3,link_tab.id,"便利リンク",10,0,nil,2,nil,nil,nil,nil,0,1,nil,nil)

