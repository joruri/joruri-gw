# -*- encoding: utf-8 -*-
class Doclibrary::Script::Conv02

  def self.convert(title_id)
    @system = 'doclibrary'
    @title = Doclibrary::Control.find(title_id)
    convert_attach
  end

  def self.convert_attach
    dump "convert_attach開始:#{Time.now}, #{@title.title}"
    table = db_alias(Doclibrary::File)
    table = table.new
    items = table.find(:all)
    for item in items
      item.content_id = 1
      file = db_alias(Doclibrary::DbFile)
      db_file = file.find_by_id(item.db_file_id)
      unless db_file.blank?
        FileUtils.mkdir_p(item.f_path) unless FileTest.exist?(item.f_path)
        File.open(item.f_name, "wb") { |f|
          f.write db_file.data
        }
      end
      item.save
      update_doc_note_link(item)
    end
    dump "convert_attach終了:#{Time.now}"
  end

  def self.update_doc_note_link(file)
    p "update_doc_note_link開始:#{Time.now}, parent_id:#{file.parent_id}"
    url = ''
    url = "#{file.file_uri(file.system_name)}" if @title.upload_system == 1
    url = "#{file.file_uri(file.system_name)}" if @title.upload_system == 2
    url = "/_admin/gwboard/receipts/#{file.id}/download_object?system=#{file.system_name}&title_id=#{file.title_id}" unless @title.upload_system == 2 unless @title.upload_system == 1

    doc_item = db_alias(Doclibrary::Doc)
    doc_item = doc_item.new
    doc_item.and :state, 'public'
    doc_item.and :title_id, @title.id
    doc_item.and :category2_id, file.parent_id
    items = doc_item.find(:all)
    for item in items
      item.note = url
      item.save
    end
    p "update_doc_note_link終了:#{Time.now}"
  end

  def self.db_alias(item)
    cnn = item.establish_connection
    cnn.spec.config[:database] = @title.dbname.to_s
    Gwboard::CommonDb.establish_connection(cnn.spec.config)
    return item
  end
end
