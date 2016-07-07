# encoding: utf-8

load "#{Rails.root}/db/seed/base.rb"

## method


def create_group(parent, level_no, sort_no, code, name, name_en)
  create_group_history(parent, level_no, sort_no, code, name, name_en)
  System::Group.create({parent_id: (parent == 0 ? 0 : parent.id),
    level_no: level_no,
    sort_no:  sort_no,
    state:    'enabled',
    ldap:      0,
    code:      code,
    name:      name,
    name_en:   name_en,
    start_at:  "#{Time.now.year}-04-01 00:00:00"})
end

def create_group_history(parent, level_no, sort_no, code, name, name_en)
  System::GroupHistory.create({parent_id: (parent == 0 ? 0 : parent.id),
    level_no:  level_no,
    sort_no:   sort_no,
    state:     'enabled',
    ldap:      0,
    code:      code,
    name:      name,
    name_en:   name_en,
    start_at:  "#{Time.now.year}-04-01 00:00:00"})
end

def create_user(auth_no, name, account, password)
  System::User.create({state: 'enabled', ldap: 0, auth_no: auth_no,
    name: name, code: account, password: password})
end

def create_user_group(options={})
  System::UsersGroup.create options
  System::UsersGroupHistory.create options
end

## system data

r = System::Group.find(1)
p = create_group r, 2, 2 , '001'   , '企画部'        , 'kikakubu'
    create_group p, 3, 1 , '001001', '秘書広報課'    , 'hisyokohoka'
    create_group p, 3, 2 , '001002', '人事課'        , 'jinjika'
    create_group p, 3, 3 , '001003', '企画政策課'    , 'kikakuseisakuka'
    create_group p, 3, 4 , '001004', '行政情報室'    , 'gyoseijohoshitsu'
    create_group p, 3, 5 , '001005', 'IT推進課'      , 'itsuishinka'
p = create_group r, 2, 3 , '002'   , '総務部'        , 'somubu'
    create_group p, 3, 1 , '002001', '財政課'        , 'zaiseika'
    create_group p, 3, 2 , '002002', '庁舎建設推進室', 'chosyakensetsusuishinka'
    create_group p, 3, 3 , '002003', '管財課'        , 'kanzaika'
    create_group p, 3, 4 , '002004', '税務課'        , 'zeimuka'
    create_group p, 3, 5 , '002005', '納税課'        , 'nozeika'
p = create_group r, 2, 4 , '003'   , '市民部'        , 'shiminbu'
p = create_group r, 2, 5 , '004'   , '環境管理部'    , 'kankyokanribu'
p = create_group r, 2, 6 , '005'   , '保健福祉部'    , 'hokenhukushibu'
p = create_group r, 2, 7 , '006'   , '産業部'        , 'sangyobu'
p = create_group r, 2, 8 , '007'   , '建設部'        , 'kensetsubu'
p = create_group r, 2, 9 , '008'   , '特定事業部'    , 'tokuteijigyobu'
p = create_group r, 2, 10, '009'   , '会計'          , 'kaikei'
p = create_group r, 2, 11, '010'   , '水道部'        , 'suidobu'
p = create_group r, 2, 12, '011'   , '教育委員会'    , 'kyoikuiinkai'
p = create_group r, 2, 13, '012'   , '議会'          , 'gikai'
p = create_group r, 2, 14, '013'   , '農業委員会'    , 'nogyoiinkai'
p = create_group r, 2, 15, '014'   , '選挙管理委員会', 'senkyokanriiinkai'
p = create_group r, 2, 16, '015'   , '監査委員'      , 'kansaiin'
p = create_group r, 2, 17, '016'   , '公平委員会'    , 'koheiiinkai'
p = create_group r, 2, 18, '017'   , '消防本部'      , 'syobohonbu'
p = create_group r, 2, 19, '018'   , '住民センター'  , 'jumincenter'
p = create_group r, 2, 20, '019'   , '公民館'        , 'kominkan'


System::User.where(id: 2).update_all(name: "徳島　太郎")
u3 = create_user 3, '徳島　花子'     , 'user2', 'user2'
u4 = create_user 3, '吉野　三郎'     , 'user3', 'user3'
u5 = create_user 3, '秘書広報課予定' , '001002_0', '001002_0'
u6 = create_user 3, '企画部予定'    , '001_0', '001_0'
u7 = create_user 3, '全庁予定'      , '1_0', '1_0'


g = System::Group.where(code: '001001').first

System::UsersGroup.where(user_id: 2).update_all(group_id: g.id)

create_user_group({user_id: u3.id, group_id: g.id, start_at: Time.now})
create_user_group({user_id: u4.id, group_id: g.id, start_at: Time.now})
create_user_group({user_id: u5.id, group_id: g.id, start_at: Time.now})
create_user_group({user_id: u6.id, group_id: g.id, start_at: Time.now})
create_user_group({user_id: u7.id, group_id: g.id, start_at: Time.now})


u8  = create_user 3, '佐藤　直一'   , 'user4', 'user4'
u9  = create_user 3, '鈴木　裕介'   , 'user5', 'user5'
u10 = create_user 3, '高橋　和寿'   , 'user6', 'user6'
u11 = create_user 3, '人事課予定'  , '001003_0', '001003_0'

g = System::Group.where(code: '001002').first
create_user_group({user_id: u8.id,  group_id: g.id, start_at: Time.now})
create_user_group({user_id: u9.id,  group_id: g.id, start_at: Time.now})
create_user_group({user_id: u10.id, group_id: g.id, start_at: Time.now})
create_user_group({user_id: u11.id, group_id: g.id, start_at: Time.now})

u12 = create_user 3, '田中　彩子'      , 'user7', 'user7'
u13 = create_user 3, '渡辺　真由子'    , 'user8', 'user8'
u14 = create_user 3, '伊藤　勝'       , 'user9', 'user9'
u15 = create_user 3, '企画政策課予定'  , '001004_0', '001004_0'

g = System::Group.where(code: '001003').first
create_user_group({user_id: u12.id, group_id: g.id, start_at: Time.now})
create_user_group({user_id: u13.id, group_id: g.id, start_at: Time.now})
create_user_group({user_id: u14.id, group_id: g.id, start_at: Time.now})
create_user_group({user_id: u15.id, group_id: g.id, start_at: Time.now})



## ---------------------------------------------------------
## load demo data

if File.exists?("#{Rails.root}/public/_attaches")
  FileUtils.rm_r("#{Rails.root}/public/_attaches/")
end

dir = "#{Rails.root}/db/seed/demo"
Dir::entries(dir).each do |file|
  next if file !~ /\.rb$/
  load "#{Rails.root}/db/seed/demo/#{file}"
end

puts "Imported demo data."
