# -*- encoding: utf-8 -*-
class Gwbbs::Script::Conv02

  def self.files_converter
    title_id = 37
    @system = 'gwbbs'
    @title = Gwbbs::Control.find(title_id)
    p "Files開始:#{Time.now}, #{@title.title}"
    @title.upload_system = 1
    table = db_alias(Gwbbs::File)
    table = table.new
    items = table.find(:all, :order=>'parent_id, id')
    for item in items
      item.content_id = 1
      file = db_alias(Gwbbs::DbFile)
      db_file = file.find_by_id(item.db_file_id)
      unless db_file.blank?
        FileUtils.mkdir_p(item.f_path) unless FileTest.exist?(item.f_path)
        File.open(item.f_name, "wb") { |f|
          f.write db_file.data
        }
      end
    end
    p "Files終了:#{Time.now}, #{@title.title}"
  end

  def self.db_alias(item)
    cnn = item.establish_connection
    cnn.spec.config[:database] = @title.dbname.to_s
    Gwboard::CommonDb.establish_connection(cnn.spec.config)
    return item
  end
end
