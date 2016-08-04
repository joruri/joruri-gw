# encoding: utf-8
## digital library
puts "Import qa demo"

def create_qa(title,options)
  admin_groups_json = options[:admin_group]  || %Q{[["", "3", "システム管理課"]]}
  adms_json         = options[:admin_json]   || "[]"
  editors_json_json = options[:editor_group] || %Q{[["", "0", "制限なし"]]}
  readers_json      = options[:reader_group] || %Q{[["", "0", "制限なし"]]}
  sort_no           = options[:sort_no] || 0
  Gwqa::Control.create({
        state: 'public',
         published_at: Time.now,
         recognize: 0,
         importance: '0',
         category: '1',
         left_index_use: '1',
         left_index_pattern: 0,
         category1_name: '分類',
         default_published: 3,
         upload_graphic_file_size_capacity: 10,
         upload_graphic_file_size_capacity_unit: 'MB',
         upload_document_file_size_capacity: 30,
         upload_document_file_size_capacity_unit: 'MB',
         upload_graphic_file_size_max: 3,
         upload_document_file_size_max: 10,
         upload_graphic_file_size_currently: 0,
         upload_document_file_size_currently: 0,
         sort_no: sort_no,
         caption: "" ,
         help_display: 1,
         upload_system: 3,
         view_hide: 1 ,
         categoey_view: 0 ,
         categoey_view_line: 0 ,
         monthly_view: 1 ,
         monthly_view_line: 6 ,
         group_view: false ,
         notification: 1 ,
         default_limit: '30',
         form_name: 'form001' ,
         title: title,
         admingrps_json: admin_groups_json,
         adms_json: adms_json,
         editors_json: editors_json_json,
         readers_json: readers_json,
         limit_date: 'none',
         docslast_updated_at:  Time.now
      })
end

def create_doc(control, options = {})
  section_code = Core.user_group.code
  section_name = Core.user_group.name
  title = options[:title] || '○○○○○'
  body = options[:body] || '○○○○○'
  doc_type = options[:doc_type] || 0
  content_state = options[:content_state] || 'unresolved'
  answer_count = options[:answer_count] || 0
  parent_id = doc_type == 1 ? options[:parent_id] : 0
  doc = Gwqa::Doc.create({
      state: 'public',
      title_id: control.id ,
      parent_id: parent_id,
      latest_updated_at: Time.now,
      importance: 1,
      one_line_note: 0,
      section_code: section_code ,
      section_name: "#{section_code}#{section_name}",
      category4_id: 0,
      category1_id: 0,
      wiki: 0,
      title: title,
      body: body,
      doc_type: doc_type,
      answer_count: answer_count,
      content_state: content_state
    })
end
g1 = System::Group.where(code: '001004').first
g2 = System::Group.where(code: '001001').first
u  = System::User.where(code: 'user1').first

qa_options = {
  admin_group: %Q{[["", "#{g1.id}", "#{g1.name}"]]},
  admin_json: %Q{[["", "#{u.id}", "#{u.name}"]]},
  editor_group: %Q{[["", "#{g1.id}", "#{g1.name}"],["", "#{g2.id}", "#{g2.name}"]]}
}

qa1 = create_qa('庁内施設利用QA',qa_options)

Gwqa::Role.create({ title_id: qa1.id, role_code: 'w', group_id: g1.id, group_code: g1.code, group_name: g1.name})
Gwqa::Role.create({ title_id: qa1.id, role_code: 'w', group_id: g2.id, group_code: g2.code, group_name: g2.name})
Gwqa::Role.create({ title_id: qa1.id, role_code: 'r', group_id: 0, group_code: '0', group_name: '制限なし'})

q1 = create_doc(qa1, {title: '公用車の利用マニュアルはどこにありますか？',body: read_data('qa/question'), answer_count: 1})
create_doc(qa1, {title: '公用車の利用マニュアルはどこにありますか？',body: read_data('qa/answer'), doc_type: 1, parent_id: q1.id})

q2 = create_doc(qa1, {title: '会議室の予約方法を知りたい',body: read_data('qa/question'), answer_count: 1, content_state: 'resolved'})
create_doc(qa1, {title: '会議室の予約方法を知りたい',body: read_data('qa/answer'), doc_type: 1, parent_id: q2.id})

create_doc(qa1, {title: '庁内にあるコピー機の配置を教えてください。',body: read_data('qa/question')})