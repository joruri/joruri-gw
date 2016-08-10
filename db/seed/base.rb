# encoding: utf-8

## ---------------------------------------------------------
## methods

def truncate_table(table)
  puts "TRUNCATE TABLE #{table}"
  ActiveRecord::Base.connection.execute "TRUNCATE TABLE #{table}"
end

## ---------------------------------------------------------
## truncate

Dir::entries("#{Rails.root}/db/seed/reset").each do |file|
  next if file !~ /\.rb$/
  load "#{Rails.root}/db/seed/reset/#{file}"
end

## ---------------------------------------------------------
## load config

core_uri   = Util::Config.load :core, :uri
core_title = Util::Config.load :core, :title

## ---------------------------------------------------------
## sys

System::Group.create({
  parent_id: 0,
  level_no:  1,
  sort_no:   1,
  state:     'enabled',
  ldap:      0,
  code:      "1",
  name:      "ジョールリ市",
  name_en:   "soshiki",
  start_at:  "#{Time.now.year}-04-01 00:00:00"
})
System::GroupHistory.create({
  parent_id: 0,
  level_no:  1,
  sort_no:   1,
  state:     'enabled',
  ldap:      0,
  code:      "1",
  name:      "ジョールリ市",
  name_en:   "soshiki",
  start_at:  "#{Time.now.year}-04-01 00:00:00"
})
System::Group.create({
  level_no:  2,
  sort_no:   1000,
  parent_id: 1,
  state:     'enabled',
  ldap:      0,
  code:      "000",
  name:      "システム管理部",
  name_en:   "sisutemkanri",
  start_at:  "#{Time.now.year}-04-01 00:00:00"
})
System::GroupHistory.create({
  level_no:  2,
  sort_no:   1000,
  parent_id: 1,
  state:     'enabled',
  ldap:      0,
  code:      "000",
  name:      "システム管理部",
  name_en:   "sisutemkanri",
  start_at:  "#{Time.now.year}-04-01 00:00:00"
})

System::Group.create({
  level_no:  3,
  sort_no:   1010,
  parent_id: 2,
  state:     'enabled',
  ldap:      0,
  code:      "000001",
  name:      "管理課",
  name_en:   "kanrika",
  start_at:  "#{Time.now.year}-04-01 00:00:00"
})

System::GroupHistory.create({
  level_no:  3,
  sort_no:   1010,
  parent_id: 2,
  state:     'enabled',
  ldap:      0,
  code:      "000001",
  name:      "管理課",
  name_en:   "kanrika",
  start_at:  "#{Time.now.year}-04-01 00:00:00"
})
System::User.create({
  state:    'enabled',
  ldap:     0,
  auth_no:  5,
  name:     "システム管理者",
  code:     "admin",
  password: "admin"
})

System::UsersGroup.create({
  user_id:  1,
  group_id: 3,
  start_at: Time.now
})
System::UsersGroupHistory.create({
  user_id:  1,
  group_id: 3,
  start_at: Time.now
})
System::User.create({
  state:    'enabled',
  ldap:     0,
  auth_no:  3,
  name:     "一般ユーザ",
  code:     "user1",
  password: "user1"
})

System::UsersGroup.create({
  user_id:  2,
  group_id: 3,
  start_at: Time.now
})

System::UsersGroupHistory.create({
  user_id:  2,
  group_id: 3,
  start_at: Time.now
})

Core.user       = System::User.where(code: 'admin').first
Core.user_group = Core.user.groups[0]

## ---------------------------------------------------------
## gw settings

Dir::entries("#{Rails.root}/db/seed/base").each do |file|
  next if file !~ /\.rb$/
  load "#{Rails.root}/db/seed/base/#{file}"
end

puts "Imported base data."
