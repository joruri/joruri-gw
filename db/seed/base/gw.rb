# encoding: utf-8
## gw configs
puts "Import gw module settings"

Gw::AdminCheckExtension.create({sort_no: 10, extension: 'jtd', remark: '一太郎'})
Gw::AdminCheckExtension.create({sort_no: 20, extension: 'xls', remark: 'Excel'})
Gw::AdminCheckExtension.create({sort_no: 30, extension: 'xlsx', remark: 'Excel 2007'})
Gw::AdminCheckExtension.create({sort_no: 40, extension: 'doc', remark: 'Word'})
Gw::AdminCheckExtension.create({sort_no: 50, extension: 'docx', remark: 'Word 2007'})
Gw::AdminCheckExtension.create({sort_no: 60, extension: 'ppt', remark: 'PowerPoint'})
Gw::AdminCheckExtension.create({sort_no: 70, extension: 'pptx', remark: 'PowerPoint 2007'})
Gw::AdminCheckExtension.create({sort_no: 80, extension: 'jac', remark: '三四郎'})
Gw::AdminCheckExtension.create({sort_no: 90, extension: 'jsd', remark: '三四郎'})


Gw::MemoMobile.create({domain: ''})
Gw::MemoMobile.create({domain: 'docomo.ne.jp'})
Gw::MemoMobile.create({domain: 'ezweb.ne.jp'})
Gw::MemoMobile.create({domain: 'softbank.ne.jp'})
Gw::MemoMobile.create({domain: 'd.vodafone.ne.jp'})
Gw::MemoMobile.create({domain: 'h.vodafone.ne.jp'})
Gw::MemoMobile.create({domain: 't.vodafone.ne.jp'})
Gw::MemoMobile.create({domain: 'c.vodafone.ne.jp'})
Gw::MemoMobile.create({domain: 'r.vodafone.ne.jp'})
Gw::MemoMobile.create({domain: 'k.vodafone.ne.jp'})
Gw::MemoMobile.create({domain: 'n.vodafone.ne.jp'})
Gw::MemoMobile.create({domain: 's.vodafone.ne.jp'})
Gw::MemoMobile.create({domain: 'q.vodafone.ne.jp'})
Gw::MemoMobile.create({domain: 'pdx.ne.jp'})


Gw::PropExtraPmRentcarUnitPrice.create({unit_price: 40,start_at: "2015-07-29 17:34:16"})

car = Gw::PropType.new({state: 'public', name: '公用車', sort_no: 100, restricted: 0})
car.id = 100
car.save

meetingroom = Gw::PropType.new({state: 'public', name: '会議室', sort_no: 200, restricted: 0})
meetingroom.id = 200
meetingroom.save

fixtures = Gw::PropType.new({state: 'public', name: '一般備品', sort_no: 300, restricted: 0})
fixtures.id = 300
fixtures.save

ActiveRecord::Base.connection.execute('ALTER TABLE gw_prop_types AUTO_INCREMENT = 400')

Gw::Reminder.create({state: 'enabled', sort_no:10, title: 'TODO', name: 'schedule_todo', css_name: 'todo'})
Gw::Reminder.create({state: 'enabled', sort_no:10, title: 'JoruriPlus+', name: 'plus_update', css_name: 'plus_update'})
Gw::Reminder.create({state: 'enabled', sort_no:20, title: '連絡メモ', name: 'memo', css_name: 'memo'})
Gw::Reminder.create({state: 'enabled', sort_no:30, title: '回覧版', name: 'circular', css_name: 'circular'})
Gw::Reminder.create({state: 'enabled', sort_no:40, title: '照会回答', name: 'monitor', css_name: 'monitor'})
Gw::Reminder.create({state: 'enabled', sort_no:50, title: 'ワークフロー', name: 'workflow', css_name: 'denshiKessai'})

Gw::SectionAdminMasterFuncName.create({func_name: 'gw_event', name: '週間・月間行事予定表', state: 'enabled', sort_no:10})
Gw::SectionAdminMasterFuncName.create({func_name: 'gw_props', name: 'レンタカー所属別実績一覧', state: 'enabled', sort_no:20})
Gw::SectionAdminMasterFuncName.create({func_name: 'gwsub_sb04', name: '電子事務分掌表', state: 'enabled', sort_no:30})


Gw::UserProperty.create({class_id:3 ,uid:0,name: 'enquete', type_name: 'help_link', options: '[[""], [""], [""], [""], [""], [""], [""]]'})
Gw::UserProperty.create({class_id:3 ,uid:0,name: 'gwmonitor', type_name: 'help_link', options: '[[""], [""]]'})
Gw::UserProperty.create({class_id:3 ,uid: 'portal_add',name: 'portal_disp_limit', type_name: 'json', options: '[["3"],["4"],["3"]]'})
Gw::UserProperty.create({class_id:3 ,uid: 'portal_add',name: 'portal_disp_option', type_name: 'json', options: '[["opened"],["opened"],["opened"]]'})
Gw::UserProperty.create({class_id:3 ,uid: 'portal_add',name: 'portal_disp_pattern', type_name: 'json', options: '4'})
Gw::UserProperty.create({class_id:3 ,uid: 0,name: 'portal', type_name: 'mode', options: '2'})


Gwworkflow::Control.create({
  state: 'public', default_published: 7, doc_body_size_capacity: 100, doc_body_size_currently: 0,
  upload_graphic_file_size_capacity: 10, upload_graphic_file_size_capacity_unit: 'GB',
  upload_graphic_file_size_max: 5, upload_document_file_size_max: 5,
  upload_graphic_file_size_currently: 0, upload_document_file_size_currently: 0,
  commission_limit: 200, left_index_use: 1, sort_no: 0, categoey_view_line: 0,
  upload_system: 3, limit_date: 'use', title: 'ワークフロー', recognize: 0,
  default_limit: 200,
  admingrps: {gid: 3},admingrps_json: '[]',adms: '',adms_json: '[]',
  editors: {gid: 3},editors_json: %Q{[["", "0", "制限なし"]]},
  readers: {gid: 3},readers_json: %Q{[["", "0", "制限なし"]]},
  sueditors: {gid: 3},sueditors_json: '[]',
  sureaders: {gid: 3},sureaders_json: '[]',
  help_display: 1
})

bbs = Gwbbs::Control.create({
     state: 'public',
     title: "全庁掲示板" ,
     published_at: Time.now,
     recognize: 0,
     importance: '1',
     category: '1',
     left_index_use: '1',
     left_index_pattern: 0,
     category1_name: '分類',
     default_published: 3,
     doc_body_size_capacity: 30,
     doc_body_size_currently: 0,
     upload_graphic_file_size_capacity: 10,
     upload_graphic_file_size_capacity_unit: 'MB',
     upload_document_file_size_capacity: 30,
     upload_document_file_size_capacity_unit: 'MB',
     upload_graphic_file_size_max: 3,
     upload_document_file_size_max: 10,
     upload_graphic_file_size_currently: 0,
     upload_document_file_size_currently: 0,
     create_section: Core.user_group.code ,
     sort_no: 0 ,
     caption: "" ,
     help_display: 1,
     upload_system: 3,
     view_hide: 1 ,
     categoey_view: 1 ,
     categoey_view_line: 0 ,
     monthly_view: 1 ,
     monthly_view_line: 6 ,
     group_view: false ,
     one_line_use: 1 ,
     notification: 1 ,
     restrict_access: 0 ,
     default_limit: '30',
     form_name: 'form001' ,
     admingrps_json:%Q{[["000001", "3", "システム管理課"]]},
     adms_json: "[]",
     editors_json: %Q{[["", "0", "制限なし"]]},
     sueditors_json: "[]",
     readers_json: %Q{[["", "0", "制限なし"]]},
     sureaders_json: "[]",
     limit_date: 'none',
     docslast_updated_at:  Time.now
    })

Gwbbs::Category.create({state: 'public', title_id: bbs.id, sort_no: 1, level_no: 1, name: 'お知らせ'})
Gwbbs::Category.create({state: 'public', title_id: bbs.id, sort_no: 2, level_no: 1, name: ' 研修案内'})
Gwbbs::Category.create({state: 'public', title_id: bbs.id, sort_no: 3, level_no: 1, name: ' 行事予定（イベント案内）'})
Gwbbs::Category.create({state: 'public', title_id: bbs.id, sort_no: 4, level_no: 1, name: ' 全庁通知'})
Gwbbs::Category.create({state: 'public', title_id: bbs.id, sort_no: 5, level_no: 1, name: ' 調査・照会'})
Gwbbs::Category.create({state: 'public', title_id: bbs.id, sort_no: 7, level_no: 1, name: ' その他'})

board_group = System::Group.where('000001').first

Gwbbs::Role.create({ title_id: bbs.id, role_code: 'w', group_id: board_group.id, group_code: '000001', group_name: '管理課'})
Gwbbs::Role.create({ title_id: bbs.id, role_code: 'a', group_id: board_group.id, group_code: '000001', group_name: '管理課'})
Gwbbs::Role.create({ title_id: bbs.id, role_code: 'r', group_id: 0, group_code: '0', group_name: '制限なし'})


Gwboard::Synthesetup.create({content_id: 2, gwbbs_check: nil, gwfaq_check: nil, gwqa_check: nil,  doclib_check: nil,  digitallib_check: nil,  limit_date: 'yesterday'})
Gwboard::Synthesetup.create({content_id: 0, gwbbs_check: 1, gwfaq_check: 1, gwqa_check: 1,  doclib_check: 1,  digitallib_check: 1,  limit_date: nil})

Gwboard::Bgcolor.create({content_id: 0, state: 'public', title: '#FFFCF0', color_code_hex: '#FFFCF0', color_code_class: 'bgColor1', pair_font_color: '#000000'})
Gwboard::Bgcolor.create({content_id: 0, state: 'public', title: '#FFE580', color_code_hex: '#FFE580', color_code_class: 'bgColor2', pair_font_color: '#000000'})
Gwboard::Bgcolor.create({content_id: 0, state: 'public', title: '#C9DCFF', color_code_hex: '#C9DCFF', color_code_class: 'bgColor3', pair_font_color: '#000000'})
Gwboard::Bgcolor.create({content_id: 0, state: 'public', title: '#0059FF', color_code_hex: '#0059FF', color_code_class: 'bgColor4', pair_font_color: '#FFFFFF'})
Gwboard::Bgcolor.create({content_id: 0, state: 'public', title: '#8875C9', color_code_hex: '#8875C9', color_code_class: 'bgColor5', pair_font_color: '#FFFFFF'})
Gwboard::Bgcolor.create({content_id: 0, state: 'public', title: '#D2FFB2', color_code_hex: '#D2FFB2', color_code_class: 'bgColor6', pair_font_color: '#000000'})
Gwboard::Bgcolor.create({content_id: 0, state: 'public', title: '#FFD4EA', color_code_hex: '#FFD4EA', color_code_class: 'bgColor7', pair_font_color: '#000000'})
Gwboard::Bgcolor.create({content_id: 0, state: 'public', title: '#FF3333', color_code_hex: '#FF3333', color_code_class: 'bgColor8', pair_font_color: '#FFFFFF'})
Gwboard::Bgcolor.create({content_id: 0, state: 'public', title: '#FFFFFF', color_code_hex: '#FFFFFF', color_code_class: 'bgColor9', pair_font_color: '#000000'})
Gwboard::Bgcolor.create({content_id: 0, state: 'public', title: '#660000', color_code_hex: '#660000', color_code_class: 'bgColor10', pair_font_color: '#FFFFFF'})
Gwboard::Bgcolor.create({content_id: 0, state: 'public', title: '#222222', color_code_hex: '#222222', color_code_class: 'bgColor11', pair_font_color: '#FFFFFF'})
Gwboard::Bgcolor.create({content_id: 0, state: 'public', title: '#C9C9C9', color_code_hex: '#C9C9C9', color_code_class: 'bgColor12', pair_font_color: '#000000'})
Gwboard::Bgcolor.create({content_id: 1, state: 'public', title: '#FFFCF0', color_code_hex: '#FFFCF0', color_code_class: 'bgColor1', pair_font_color: '#000000'})
Gwboard::Bgcolor.create({content_id: 1, state: 'public', title: '#FFE580', color_code_hex: '#FFE580', color_code_class: 'bgColor2', pair_font_color: '#000000'})
Gwboard::Bgcolor.create({content_id: 1, state: 'public', title: '#C9DCFF', color_code_hex: '#C9DCFF', color_code_class: 'bgColor3', pair_font_color: '#000000'})
Gwboard::Bgcolor.create({content_id: 1, state: 'public', title: '#0059FF', color_code_hex: '#0059FF', color_code_class: 'bgColor4', pair_font_color: '#FFFFFF'})
Gwboard::Bgcolor.create({content_id: 1, state: 'public', title: '#8875C9', color_code_hex: '#8875C9', color_code_class: 'bgColor5', pair_font_color: '#FFFFFF'})
Gwboard::Bgcolor.create({content_id: 1, state: 'public', title: '#D2FFB2', color_code_hex: '#D2FFB2', color_code_class: 'bgColor6', pair_font_color: '#000000'})
Gwboard::Bgcolor.create({content_id: 1, state: 'public', title: '#FFD4EA', color_code_hex: '#FFD4EA', color_code_class: 'bgColor7', pair_font_color: '#000000'})
Gwboard::Bgcolor.create({content_id: 1, state: 'public', title: '#FF3333', color_code_hex: '#FF3333', color_code_class: 'bgColor8', pair_font_color: '#FFFFFF'})
Gwboard::Bgcolor.create({content_id: 1, state: 'public', title: '#FFFFFF', color_code_hex: '#FFFFFF', color_code_class: 'bgColor9', pair_font_color: '#000000'})
Gwboard::Bgcolor.create({content_id: 1, state: 'public', title: '#660000', color_code_hex: '#660000', color_code_class: 'bgColor10', pair_font_color: '#FFFFFF'})
Gwboard::Bgcolor.create({content_id: 1, state: 'public', title: '#000000', color_code_hex: '#000000', color_code_class: 'bgColor11', pair_font_color: '#FFFFFF'})
Gwboard::Bgcolor.create({content_id: 1, state: 'public', title: '#C9C9C9', color_code_hex: '#C9C9C9', color_code_class: 'bgColor12', pair_font_color: '#000000'})


circular = Gwcircular::Control.create({
  state: 'public', default_published: 7, doc_body_size_capacity: 100, doc_body_size_currently: 0,
  upload_graphic_file_size_capacity: 10, upload_graphic_file_size_capacity_unit: 'GB',
  upload_graphic_file_size_max: 5, upload_document_file_size_max: 5,
  upload_graphic_file_size_currently: 0, upload_document_file_size_currently: 0,
  commission_limit: 200, left_index_use: 1, sort_no: 0, categoey_view_line: 0,
  upload_system: 3, limit_date: 'use', title: '回覧板', recognize: 0,
  default_limit: 200,
  admingrps: {gid: 3},admingrps_json: '[]',adms: '',adms_json: '[]',
  editors: {gid: 3},editors_json: %Q{[["", "0", "制限なし"]]},
  readers: {gid: 3},readers_json: %Q{[["", "0", "制限なし"]]},
  sueditors: {gid: 3},sueditors_json: '[]',
  sureaders: {gid: 3},sureaders_json: '[]',
  help_display: 1
})

Gwcircular::Role.create({ title_id: circular.id, role_code: 'r', group_id: 0, group_code: '0', group_name: '制限なし'})

Gwmonitor::Form.create({sort_no:0, level_no: 0, form_name: 'form001', form_caption: 'テキスト形式'})
Gwmonitor::Form.create({sort_no:10, level_no: 10, form_name:  'form002', form_caption: '複数行形式'})
