# encoding: utf-8
## digital library
puts "Import doclibrary demo"

def create_doclib(title)
  Doclibrary::Control.create({
        state: 'public' ,
        published_at: Core.now ,
        importance: '1' ,
        category: '1' ,
        left_index_use: '1',
        category1_name: 'ルートフォルダ' ,
        recognize: '0' ,
        default_published: 3,
        upload_graphic_file_size_capacity: 10,
        upload_graphic_file_size_capacity_unit: 'MB',
        upload_document_file_size_capacity: 30,
        upload_document_file_size_capacity_unit: 'MB',
        upload_graphic_file_size_max: 3,
        upload_document_file_size_max: 10,
        upload_graphic_file_size_currently: 0,
        upload_document_file_size_currently: 0,
        sort_no: 0 ,
        view_hide: 1 ,
        upload_system: 3 ,
        notification: 1 ,
        help_display: '1' ,
        create_section: '' ,
        categoey_view: 1 ,
        categoey_view_line: 0 ,
        monthly_view: 1 ,
        monthly_view_line: 6 ,
        default_limit: '20',
        form_name: 'form001',
        title: title,
        admingrps_json: %Q{[["", "3", "システム管理課"]]},
        adms_json: "[]",
        sueditors_json: [["","2","徳島太郎"]],
        readers_json: %Q{[["", "0", "制限なし"]]}
      })
end

def create_doc(parent, options = {})
  section_code = Core.user_group.code
  section_name = Core.user_group.name
  title = options[:title] || '○○○○○'
  body = options[:body] || '○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○<br />○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○○<br />'
  Doclibrary::Doc.create({
      state: 'public',
      title_id: parent.title_id ,
      latest_updated_at: Time.now,
      importance: 1,
      one_line_note: 0,
      section_code: section_code ,
      section_name: "#{section_code}#{section_name}",
      category4_id: 0,
      category1_id: parent.id,
      wiki: 0,
      title: title,
      body: body
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
end


first_library = create_doclib('議事録')


Doclibrary::Role.create({ title_id: first_library.id, role_code: 'w', user_id: 2 , user_code: 'user1', user_name: '徳島太郎'})
Doclibrary::Role.create({ title_id: first_library.id, role_code: 'r', group_id: 0, group_code: '0', group_name: '制限なし'})


parent_folder = Doclibrary::Folder.where(title_id: first_library.id).first

doc1 = create_doc(parent_folder, {title: 'ABCDに関する会議議事録', body: read_data('doclibrary/1/body')})

doc2 = create_doc(parent_folder, {title: '第１回　会議議事録', body: read_data('doclibrary/2/body')})
create_file(first_library, doc2, "#{Rails.root}/db/seed/files/doclibrary/1.pdf", {filename: '議事録　○○○○○○○○○○○○○○○○○○○○○について.pdf'})

doc3 = create_doc(parent_folder, {title: '第２回　会議議事録', body: read_data('doclibrary/3/body')})
create_file(first_library, doc3, "#{Rails.root}/db/seed/files/doclibrary/1.odt", {filename: '議事録　○○○○○○○○○○○○○○○○○○○○○について.odt'})
create_file(first_library, doc3, "#{Rails.root}/db/seed/files/doclibrary/1.ods", {filename: '四国４県.ods'})

second_library = create_doclib('報告書')

Doclibrary::Role.create({ title_id: second_library.id, role_code: 'w', user_id: 2 , user_code: 'user1', user_name: '徳島太郎'})
Doclibrary::Role.create({ title_id: second_library.id, role_code: 'r', group_id: 0, group_code: '0', group_name: '制限なし'})

parent_folder = Doclibrary::Folder.where(title_id: second_library.id).first

doc1 = create_doc(parent_folder, {title: '△△に関する報告書', body: read_data('doclibrary/4/body')})
create_file(second_library, doc1, "#{Rails.root}/db/seed/files/doclibrary/2.odt", {filename: '報告書.odt'})
create_file(second_library, doc1, "#{Rails.root}/db/seed/files/doclibrary/1.ods", {filename: '四国４県.ods'})


doc2 = create_doc(parent_folder, {title: '○○についての報告書', body: read_data('doclibrary/5/body')})

create_file(second_library, doc2, "#{Rails.root}/db/seed/files/doclibrary/2.pdf", {filename: '報告書.pdf'})



third_library = create_doclib('文書ライブラリ')

Doclibrary::Role.create({ title_id: third_library.id, role_code: 'w', user_id: 2 , user_code: 'user1', user_name: '徳島太郎'})
Doclibrary::Role.create({ title_id: third_library.id, role_code: 'r', group_id: 0, group_code: '0', group_name: '制限なし'})

parent_folder = Doclibrary::Folder.where(title_id: third_library.id).first

doc1 = create_doc(parent_folder, {title: '平成２４年度グループウェア運用責任者一覧', body: read_data('doclibrary/6/body')})
create_file(third_library, doc1, "#{Rails.root}/db/seed/files/doclibrary/1.xls", {filename: '運用責任者.xls'})



