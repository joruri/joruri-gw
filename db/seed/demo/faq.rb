# encoding: utf-8
## digital library
puts "Import faq demo"

def create_faq(title,options)
  admin_groups_json = options[:admin_group]  || %Q{[["", "3", "システム管理課"]]}
  adms_json         = options[:admin_json]   || "[]"
  editors_json_json = options[:editor_group] || %Q{[["", "0", "制限なし"]]}
  readers_json      = options[:reader_group] || %Q{[["", "0", "制限なし"]]}
  sort_no           = options[:sort_no] || 0
  Gwfaq::Control.create({
        state: 'public',
         published_at: Time.now,
         recognize: 0,
         importance: '0',
         category: '0',
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
  doc = Gwfaq::Doc.create({
      state: 'public',
      title_id: control.id ,
      latest_updated_at: Time.now,
      importance: 1,
     one_line_note: 0,
      section_code: section_code ,
      section_name: "#{section_code}#{section_name}",
      category4_id: 0,
      category1_id: 0,
      wiki: 0,
      title: title,
      body: body
    })
end
g1 = System::Group.where(code: '001004').first
g2 = System::Group.where(code: '001001').first
u  = System::User.where(code: 'user1').first

faq_options = {
  admin_group: %Q{[["", "#{g1.id}", "#{g1.name}"]]},
  admin_json: %Q{[["", "#{u.id}", "#{u.name}"]]},
  editor_group: %Q{[["", "#{g1.id}", "#{g1.name}"],["", "#{g2.id}", "#{g2.name}"]]}
}

faq1 = create_faq('防災FAQ',faq_options)

Gwfaq::Role.create({ title_id: faq1.id, role_code: 'w', group_id: g1.id, group_code: g1.code, group_name: g1.name})
Gwfaq::Role.create({ title_id: faq1.id, role_code: 'w', group_id: g2.id, group_code: g2.code, group_name: g2.name})
Gwfaq::Role.create({ title_id: faq1.id, role_code: 'r', group_id: 0, group_code: '0', group_name: '制限なし'})


create_doc(faq1, {title: '自宅で揺れを感じたら',body: read_data('faq/1/body')})
create_doc(faq1, {title: '寝ているときに揺れを感じたら',body: read_data('faq/2/body')})
