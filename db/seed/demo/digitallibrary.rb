# encoding: utf-8
## digital library
puts "Import digitallibrary demo"

def create_folder(parent, title)
  Digitallibrary::Folder.create({
      state: 'public' ,
      latest_updated_at: Time.now,
      parent_id: parent.id ,
      chg_parent_id: parent.id ,
      title_id: parent.title_id,
      doc_type: 0 ,
      level_no: parent.level_no + 1,
      section_code: Core.user_group.code,
      sort_no: Digitallibrary::Doc::MAX_SEQ_NO,
      order_no: Digitallibrary::Doc::MAX_SEQ_NO,
      display_order: 100,  #
      seq_no: Digitallibrary::Doc::MAX_SEQ_NO.to_f,
      title: title
    })
end

def create_doc(parent, options = {})
  title = options[:title] || '○○○○○'
  body = options[:body] || '○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○<br />'
  Digitallibrary::Doc.create(
        state: 'public',
        latest_updated_at: Time.now,
        parent_id: parent.id ,
        chg_parent_id: parent.id ,
        title_id: parent.title_id ,
        doc_alias: 0,
        doc_type: 1,
        level_no: parent.level_no + 1,
        seq_no: Digitallibrary::Doc::MAX_SEQ_NO,
        order_no: Digitallibrary::Doc::MAX_SEQ_NO.to_i,
        sort_no: Digitallibrary::Doc::MAX_SEQ_NO.to_i,
        display_order: 100,
        section_code: Core.user_group.code,
        category4_id: 0,
        category1_id: parent.id ,
        wiki: 0,
        title: title,
        body: body
      )
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
end


first_library = Digitallibrary::Control.create({
      state: 'public' ,
      published_at: Time.now ,
      importance: '1' ,
      category: '0' ,
      left_index_use: '1',
      category1_name: '見出し' ,
      recognize: '0' ,
      default_published: 3,
      upload_graphic_file_size_capacity: 30,
      upload_graphic_file_size_capacity_unit: 'MB',
      upload_document_file_size_capacity: 60,
      upload_document_file_size_capacity_unit: 'MB',
      upload_graphic_file_size_max: 3,
      upload_document_file_size_max: 4,
      upload_graphic_file_size_currently: 0,
      upload_document_file_size_currently: 0,
      upload_system: '3',
      sort_no: 0 ,
      view_hide: 1 ,
      categoey_view: 1 ,
      categoey_view_line: 0 ,
      monthly_view: 1 ,
      monthly_view_line: 6 ,
      default_limit: '20',
      form_name: 'form001',
      title: '○○規定',
      separator_str1: '.',
      separator_str2: '.',
      admingrps_json: %Q{[["000001", "3", "システム管理課"]]},
      adms_json: "[]",
      sueditors_json: [["user1","1","徳島太郎"]],
      readers_json: %Q{[["", "0", "制限なし"]]}
    })


Digitallibrary::Role.create({ title_id: first_library.id, role_code: 'w', user_id: 2 , user_code: 'user1', user_name: '徳島太郎'})
Digitallibrary::Role.create({ title_id: first_library.id, role_code: 'r', group_id: 0, group_code: '0', group_name: '制限なし'})


parent_folder = Digitallibrary::Folder.where(title_id: first_library.id).first

2.times do |i|
  create_doc(parent_folder)
end

folder_1 = create_folder(parent_folder, '□□□□□□□□□□')

4.times do |i|
  create_doc(folder_1)
end

folder_2 = create_folder(parent_folder, '☆☆☆☆☆☆☆☆')

3.times do |i|
  create_doc(folder_2)
end

folder_2_1 = create_folder(folder_2, '●●●●●●●●●●●')

3.times do |i|
  create_doc(folder_2_1)
end

seond_library = Digitallibrary::Control.create({
      state: 'public' ,
      published_at: Time.now ,
      importance: '1' ,
      category: '0' ,
      left_index_use: '1',
      category1_name: '見出し' ,
      recognize: '0' ,
      default_published: 3,
      upload_graphic_file_size_capacity: 30,
      upload_graphic_file_size_capacity_unit: 'MB',
      upload_document_file_size_capacity: 60,
      upload_document_file_size_capacity_unit: 'MB',
      upload_graphic_file_size_max: 3,
      upload_document_file_size_max: 4,
      upload_graphic_file_size_currently: 0,
      upload_document_file_size_currently: 0,
      upload_system: '3',
      sort_no: 0 ,
      view_hide: 1 ,
      categoey_view: 1 ,
      categoey_view_line: 0 ,
      monthly_view: 1 ,
      monthly_view_line: 6 ,
      default_limit: '20',
      form_name: 'form001',
      title: 'グループウェア利用マニュアル',
      separator_str1: '.',
      separator_str2: '.',
      admingrps_json: %Q{[["000001", "3", "システム管理課"]]},
      adms_json: "[]",
      sueditors_json: [["user1","1","徳島太郎"]],
      readers_json: %Q{[["", "0", "制限なし"]]}
    })


Digitallibrary::Role.create({ title_id: seond_library.id, role_code: 'w', user_id: 2 , user_code: 'user1', user_name: '徳島太郎'})
Digitallibrary::Role.create({ title_id: seond_library.id, role_code: 'r', group_id: 0, group_code: '0', group_name: '制限なし'})

parent_folder = Digitallibrary::Folder.where(title_id: seond_library.id).first

folder_1 = create_folder(parent_folder, 'ポータル')
doc1 = create_doc(folder_1,{title: 'ポータル画面', body: 'ポータル画面の利用マニュアルを３冊開示します。<br />ご利用ください。'})

files = [
  ["#{Rails.root}/db/seed/files/digitallibrary/1.pdf", {filename: '利用マニュアル - (1).pdf'}],
  ["#{Rails.root}/db/seed/files/digitallibrary/2.pdf", {filename: '利用マニュアル - (2).pdf'}],
  ["#{Rails.root}/db/seed/files/digitallibrary/3.pdf", {filename: '利用マニュアル - (3).pdf'}]
]
files.each do |file|
  create_file(seond_library, doc1, file[0], file[1])
end

folder_2 = create_folder(parent_folder, '機能')

doc2 = create_doc(folder_2,{title: 'スケジューラ利用マニュアル', body: 'スケジューラ利用マニュアルを開示します。'})
create_file(seond_library, doc2, "#{Rails.root}/db/seed/files/digitallibrary/4.pdf", {filename: '利用マニュアル - (4).pdf'})


doc3 = create_doc(folder_2,{title: 'ToDo利用マニュアル', body: 'ToDo利用マニュアルを開示します。'})
create_file(seond_library, doc3, "#{Rails.root}/db/seed/files/digitallibrary/5.pdf", {filename: '利用マニュアル - (5).pdf'})

