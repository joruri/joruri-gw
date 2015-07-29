# -*- encoding: utf-8 -*-
#######################################################################
#
#
#######################################################################

class Digitallibrary::Script::Conv

  #添付ファイルDB->実体
  def self.convert(title_id)
    files_converter(title_id)
    #images_converter(title_id)
  end

  #
  def self.files_converter(title_id)
    @system = 'digitallibrary'
    @title = Digitallibrary::Control.find(title_id)
    p "Files開始:#{Time.now}, #{@title.title}"
    table = db_alias(Digitallibrary::File)
    table = table.new
    items = table.find(:all, :order=>'parent_id, id')
    for item in items
      #content_id=2は実ファイルをアクセス制御付きで管理する
      item.content_id = 1
      file = db_alias(Digitallibrary::DbFile)
      db_file = file.find_by_id(item.db_file_id)
      unless db_file.blank?
        FileUtils.mkdir_p(item.f_path) unless FileTest.exist?(item.f_path)
       #dump "f_name:#{item.f_name}"
        File.open(item.f_name, "wb") { |f|
          f.write db_file.data
        }
      end
      item.save
    end
    p "Files終了:#{Time.now}"
  end

  #
  def self.images_converter(title_id)
    @system = 'digitallibrary'
    @title = Digitallibrary::Control.find(title_id)
    p "Images開始:#{Time.now}, #{@title.title}"
    read_items = db_alias(Digitallibrary::Image)
    read_items = read_items.find(:all)
    for read_item in read_items

      item = db_alias(Digitallibrary::Doc)
      item = item.new
      item.and :title_id , title_id
      item.and :id , read_item.parent_id
      doc = item.find(:first)
      if doc
        item = db_alias(Digitallibrary::File)
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

    Digitallibrary::Doc.remove_connection
    Digitallibrary::File.remove_connection
    Digitallibrary::Image.remove_connection
    p "Images終了:#{Time.now}"
  end

  #gwbbs_controlsに設定されているdatabase接続先を参照する
  def self.db_alias(item)
    cnn = item.establish_connection
    #コントロールにdbnameが設定されているdbname名で接続する
    cnn.spec.config[:database] = @title.dbname.to_s
    Gwboard::CommonDb.establish_connection(cnn.spec.config)
    return item
  end
end
