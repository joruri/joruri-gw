# -*- encoding: utf-8 -*-
class Gwbbs::Script::Conv

  def self.convert(title_id, link)
    files_converter(title_id, link)
    #images_converter(title_id)
  end

  def self.files_converter(title_id, link)
    @system = 'gwbbs'
    @title = Gwbbs::Control.find(title_id)
    p "Files開始:#{Time.now}, #{@title.title}"
    table = db_alias(Gwbbs::File)
    table = table.new
    items = table.find(:all, :order=>'parent_id, id')
    brk_id = 0
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
      item.save

      if link == 99
        if brk_id == item.parent_id
          str_add = ''
        else
          str_add = "<p>&nbsp;</p><p>&nbsp;</p>"
        end
        brk_id = item.parent_id
        update_doc_link(item,str_add)
      end
    end
    p "Files終了:#{Time.now}, #{@title.title}"
  end

  def self.update_doc_link(item,str_add)
    doc_item = db_alias(Gwbbs::Doc)
    doc_item = doc_item.new
    doc_item.and :id, item.parent_id
    doc_item = doc_item.find(:first)
    unless doc_item.blank?
      str = str_add
      str += "<a href=" + item.file_uri(@system) + " class=\"" + item.icon_type + "\">" + %Q[#{item.filename} (#{item.eng_unit})] + "</a>"
      doc_item.body = "#{doc_item.body}#{str}"
      doc_item._no_validation = true
      doc_item.save
    end
  end

  def self.images_converter(title_id)
    @system = 'gwbbs'
    @title = Gwbbs::Control.find(title_id)
    p "Images開始:#{Time.now}, #{@title.title}"
    read_items = db_alias(Gwbbs::Image)
    read_items = read_items.find(:all)
    for read_item in read_items

      item = db_alias(Gwbbs::Doc)
      item = item.new
      item.and :title_id , title_id
      item.and :id , read_item.parent_id
      doc = item.find(:first)
      if doc
        item = db_alias(Gwbbs::File)
        image_file_path = "#{RAILS_ROOT}/public#{read_item.image_file_path}"
        @item = item.new({
          :state => doc.state ,
          :content_type => read_item.content_type ,
          :filename => read_item.filename ,
          :size => read_item.size ,
          :memo => "images_id:#{read_item.id}" ,
          :title_id => read_item.title_id ,
          :parent_id => read_item.parent_id ,
          :content_id => @title.upload_system ,
          :db_file_id => -1  #データ変換確認後　0　に一括更新予定
        })

        f = open(image_file_path, "rb")
        fil = f.read
        f.close
        @item._upload_file(fil)

        @item.save
      end
    end

    Gwbbs::Doc.remove_connection
    Gwbbs::File.remove_connection
    Gwbbs::Image.remove_connection
    p "Images終了:#{Time.now}"
  end

  def self.db_alias(item)
    cnn = item.establish_connection
    cnn.spec.config[:database] = @title.dbname.to_s
    Gwboard::CommonDb.establish_connection(cnn.spec.config)
    return item
  end
end
