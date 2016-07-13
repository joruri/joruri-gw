# encoding: utf-8
## digital library
puts "Import bbs demo"

def create_board(title,options)
  admin_groups_json = options[:admin_group]  || %Q{[["000001", "3", "システム管理課"]]}
  editors_json_json = options[:editor_group] || %Q{[["", "0", "制限なし"]]}
  readers_json      = options[:reader_group] || %Q{[["", "0", "制限なし"]]}
  sort_no           = options[:sort_no] || 0
  create_section    = options[:create_section] || nil
  Gwbbs::Control.create({
        state: 'public',
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
         create_section: create_section,
         sort_no: sort_no,
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
         title: title,
         admingrps_json: admin_groups_json,
         adms_json: "[]",
         editors_json: editors_json_json,
         readers_json: readers_json,
         limit_date: 'none',
         docslast_updated_at:  Time.now
      })
end

def create_doc(control, category, options = {})
  str_section_code = Core.user_group.code
  title = options[:title] || '○○○○○'
  body = options[:body] || '○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○<br />'
  doc = Gwbbs::Doc.create({
      state: 'public',
      title_id: control.id ,
      latest_updated_at: Time.now,
      importance: 1,
      one_line_note: 0,
      section_code: str_section_code ,
      category4_id: 0,
      category1_id: category.id,
      wiki: 0,
      title: title,
      body: body,
      able_date: Time.now.strftime("%Y-%m-%d"),
      expiry_date: (control.default_published || 3).months.since.strftime("%Y-%m-%d"),
    })
end

def create_file(control, parent, file_path, file_attributes)
  doc_file = control.files.build(
      file: Sys::Lib::File::NoUploadedFile.new(file_path, file_attributes),
      memo: '',
      parent_id: parent.id,
      content_id: control.upload_system,
      db_file_id: 0
    )
  doc_file.save
  return doc_file
end

bbs1 = Gwbbs::Control.first
category = Gwbbs::Category.where(title_id: bbs1.id, name: ' 研修案内').first
doc1 = create_doc(bbs1, category, {title: '初心者向けプログラミング勉強会のお知らせ'})
file1 = create_file(bbs1, doc1, "#{Rails.root}/db/seed/files/gwbbs/1.pdf", {filename: '初心者向けプログラミング勉強会のお知らせ.pdf'})
file_body = %Q(<a class="#{file1.icon_type}" href="#{file1.file_uri('gwbbs')}">#{file1.filename}</a>)
Gwbbs::Doc.where(id: doc1.id).update_all(body: file_body)

emergency_board_groups = []

groups = System::Group.where(code: ['001001','001002','001003'])
i = 1
groups.each do |group|
  options = {
    admin_group: %Q{[["#{group.code}", "3", "#{group.name}"]]},
    editor_group: %Q{[["#{group.code}", "3", "#{group.name}"]]},
    reader_group: %Q{[["#{group.code}", "3", "#{group.name}"]]},
    sort_no: i * 10,
    create_section: group.code
  }
  board_item = create_board(%Q(#{group.name}掲示板),options)
  Gwbbs::Role.create({ title_id: board_item.id, role_code: 'w', group_id: group.id, group_code: group.code, group_name: group.name})
  Gwbbs::Role.create({ title_id: board_item.id, role_code: 'a', group_id: group.id, group_code: group.code, group_name: group.name})
  Gwbbs::Role.create({ title_id: board_item.id, role_code: 'r', group_id: group.id, group_code: group.code, group_name: group.name})
  emergency_board_groups << %Q{["#{group.code}", "3", "#{group.name}"]}
  i+=1
end

emergency_board_group_json = "["
emergency_board_group_json += emergency_board_groups.join(',')
emergency_board_group_json += "]"

emergency_options = {
  admin_group: emergency_board_group_json,
  editor_group: emergency_board_group_json,
  sort_no: 5
}
emergency_bbs = create_board(%Q(防災掲示板),emergency_options)
groups.each do |group|
  Gwbbs::Role.create({ title_id: emergency_bbs.id, role_code: 'w', group_id: group.id, group_code: group.code, group_name: group.name})
  Gwbbs::Role.create({ title_id: emergency_bbs.id, role_code: 'a', group_id: group.id, group_code: group.code, group_name: group.name})
  Gwbbs::Role.create({ title_id: emergency_bbs.id, role_code: 'r', group_id: group.id, group_code: group.code, group_name: group.name})
end
