# encoding: utf-8
## attendance
puts "Import attendance demo"

def create_member(state, g_order, g_name, u_order, u_lname, u_name)
  Gw::PrefAssemblyMember.create({
    state: state,
    g_order: g_order,
    g_name: g_name,
    u_order: u_order,
    u_lname: u_lname,
    u_name: u_name
  })
end

def create_executive(state, uid, u_order, title)
  Gw::PrefExecutive.create({
    state: state,
    uid: uid,
    u_order: u_order,
    title: title,
    is_other_view: 1
  })
end

def create_director(uid, u_order, title)
  Gw::PrefDirector.create({
    uid: uid,
    u_order: u_order,
    title: title,
    is_governor_view: 1
  })
end

create_member 'on',  10, '議長',   10,  '徳島',   '太郎'
create_member 'on',  20, '副議長',  20,  '阿波',  '花子'
create_member 'on', 30, '○○会',   30,  '吉野',  '三郎'
create_member 'off',  30, '○○会',   40,  '佐藤',  '直一'
create_member 'off', 40, '◇◇会',   50,  '鈴木',  '裕介'
create_member 'on',  40, '◇◇会',   60,  '高橋',  '和寿'

u = System::User.find_by(code: 'user1')
create_executive 'on', u.id, 10, '知事'   if u.present?
create_director  u.id, 10, '○○長'   if u.present?

u = System::User.find_by(code: 'user2')
create_executive 'off', u.id, 20, '副知事'  if u.present?
create_director  u.id, 20, '○○長'   if u.present?

u = System::User.find_by(code: 'user3')
create_executive 'on', u.id, 30, '政策監'  if u.present?
create_director  u.id, 30, '○○長'   if u.present?

u = System::User.find_by(code: 'user4')
create_executive 'off', u.id, 40, '政策監補' if u.present?
create_director  u.id, 40, '○○長'  if u.present?

u = System::User.find_by(code: 'user5')
create_executive 'off', u.id, 50, '役職１' if u.present?
create_director  u.id, 50, '○○長'  if u.present?

u = System::User.find_by(code: 'user6')
create_executive 'on', u.id, 60, '役職２' if u.present?
create_director  u.id, 60, '○○長'  if u.present?

u = System::User.find_by(code: 'user7')
create_director  u.id, 70, '○○長'  if u.present?

u = System::User.find_by(code: 'user8')
create_director  u.id, 80, '○○長'  if u.present?
