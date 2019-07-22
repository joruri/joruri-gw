# encoding: utf-8
## gwsub
puts "Import sb04 demo"


fyed_id_today = Gw::YearFiscalJp.get_record(Date.today)

Gwsub::Sb04EditableDate.create({
  fyear_id: fyed_id_today.id,
  fyear_markjp: fyed_id_today.markjp,
  published_at: fyed_id_today.start_at,
  start_at: fyed_id_today.start_at,
  end_at:  (fyed_id_today.start_at + 10.days),
  headline_at: fyed_id_today.start_at
})

official_titles = ['部長','課長','係長','主任','総合職','技術職','事務職']

7.times do |i|
  Gwsub::Sb04officialtitle.create({
    fyear_id: fyed_id_today.id,
    fyear_markjp: fyed_id_today.markjp,
    code_int: i * 100,
    code: "#{(i * 100)}",
    name: official_titles[(i-1)]
  })
end

System::Group.where(state: 'enabled').order(:sort_no).each do |g|
  Gwsub::Sb04section.create({
    fyear_id: fyed_id_today.id,
    fyear_markjp: fyed_id_today.markjp,
    code: g.code,
    name: g.name,
    ldap_code: g.code,
    ldap_name: g.name
  })
end

Gwsub::Sb04section.where(fyear_id: fyed_id_today.id).each do |g|
  target_code = case g.code
  when '001'
    [{code_int: 10, code: 10, name: nil, tel: '000-000-0000', address: '(〒XXX-XXXX) ＸＸ県ジョールリ市XXXXXX町1-1', remark: 'サンプルです'}]
  when '001002'
    [
      {code_int: 10, code: 10, name: nil, tel: nil, address: 'ジョールリ市○○町1番地 ／ 000-000-0000'},
      {code_int: 20, code: 20, name: '広報担当', tel: nil, address: nil},
      {code_int: 30, code: 30, name: '情報担当', tel: nil, address: nil}
    ]
  when '001003'
    [
      {code_int: 10, code: 10, name: nil, tel: nil, address: 'ジョールリ市○○町1番地 ／ 000-000-0000'},
      {code_int: 20, code: 20, name: '人事担当', tel: nil, address: nil},
      {code_int: 30, code: 30, name: '研修担当', tel: nil, address: nil}
    ]
  when '002003'
    [
      {code_int: 10, code: 10, name: nil, tel: nil, address: 'ジョールリ市○○町1番地 ／ 000-000-0000'},
      {code_int: 20, code: 20, name: '設備担当', tel: nil, address: nil},
      {code_int: 30, code: 30, name: '調達担当', tel: nil, address: nil}
    ]
  when '002007'
    [
      {code_int: 10, code: 10, name: nil, tel: nil, address: 'ジョールリ市○○町1番地 ／ 000-000-0000'},
      {code_int: 20, code: 20, name: '危機管理全般', tel: nil, address: nil},
      {code_int: 30, code: 30, name: '食品担当', tel: nil, address: nil},
      {code_int: 30, code: 40, name: '交通担当', tel: nil, address: nil},
    ]
  else
    [{code_int: 10, code: 10, name: nil, tel: nil, address: nil}]
  end

  target_code.each do |c|
    Gwsub::Sb04assignedjob.create({
      fyear_id: fyed_id_today.id,
      fyear_markjp: fyed_id_today.markjp,
      section_id: g.id,
      section_code: g.code,
      section_name: g.name,
      code_int: c[:code_int],
      code: c[:code],
      name: c[:code],
      tel: c[:tel],
      address: c[:address],
      remarks: c[:remarks]
    })
  end
end

Gwsub::Sb04section.where(fyear_id: fyed_id_today.id, code: ['001002','001003']).each do |g|
  target_user = case g.code
  when '001002'
    [
      {staff_no: 'user3', assignedjobs_code: 10, official_title_code: 200, duties: '安全対策', extension: '0000'},
      {staff_no: 'user2', assignedjobs_code: 10, official_title_code: 400, duties: '業務企画', extension: '0001'},
      {staff_no: 'user1', assignedjobs_code: 10, official_title_code: 500, duties: '防犯対策', extension: '0003'},
    ]
  when '001003'
    [
      {staff_no: 'user4', assignedjobs_code: 10, official_title_code: 200, duties: '組織企画', extension: '1000'},
      {staff_no: 'user5', assignedjobs_code: 10, official_title_code: 300, duties: 'ハラスメント対策', extension: '1001'},
      {staff_no: 'user6', assignedjobs_code: 10, official_title_code: 700, duties: '人事考課', extension: '1002'},
    ]
   else
    next
   end

   target_user.each do |u|
    system_user = System::User.find_by(code: u[:staff_no])
    next if system_user.blank?
    assignedjob = Gwsub::Sb04assignedjob.where(fyear_id: fyed_id_today.id,
      section_code: g.code, code: u[:assignedjobs_code]).first
    next if assignedjob.blank?
    official_title = Gwsub::Sb04officialtitle.where(fyear_id: fyed_id_today.id,
      code: u[:official_title_code]).first
    next if official_title.blank?
    Gwsub::Sb04stafflist.create({
      fyear_id: fyed_id_today.id,
      fyear_markjp: fyed_id_today.markjp,
      multi_section_flg: 1,
      staff_no: system_user.code,
      name: system_user.name,
      name_print: system_user.name,
      kana: system_user.kana,
      section_id: g.id,
      section_code: g.code,
      section_name: g.name,
      assignedjobs_id: assignedjob.id,
      assignedjobs_code_int: assignedjob.code_int,
      assignedjobs_code: assignedjob.code,
      assignedjobs_name: assignedjob.name,
      assignedjobs_tel: assignedjob.tel,
      assignedjobs_address: assignedjob.address,
      official_title_id: official_title.id,
      official_title_code: official_title.code,
      official_title_code_int: official_title.code_int,
      official_title_name: official_title.name,
      extension: u[:extension],
      divide_duties: u[:duties],
      personal_state: 1,
      display_state: 1,
    })
   end
end

