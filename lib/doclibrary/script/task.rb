# -*- encoding: utf-8 -*-
#######################################################################
#
#
#######################################################################

class Doclibrary::Script::Task

  def self.preparation_delete
    dump "#{self}, 不要データ削除処理開始：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    item = Doclibrary::Control.new
    items = item.find(:all)
    for rec_item in items
      destroy_record(rec_item.id)
    end
    dump "#{self}, 不要データ削除処理終了：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  end

  def self.destroy_record(id)
    @title = Doclibrary::Control.find_by_id(id)
    message = "データベース名：#{@title.dbname}, 書庫名：#{@title.title}"

    del_count = 0
    unless @title.blank?
#      p "#{@title.dbname}処理開始."
      begin
        @img_path = "public/_common/modules/#{@title.system_name}/"   #画像path指定
        item = db_alias(Doclibrary::Doc)
        limit = Gwbbs::Script::Task.preparation_get_limit_date
        #不要データを削除する
        doc_item = item.new
        doc_item.and :state, 'preparation'
        doc_item.and :created_at, '<', "#{limit.strftime("%Y-%m-%d")} 00:00:00"
        @items = doc_item.find(:all)
        for @item in @items
          destroy_dbfiles
         #destroy_image_files
          destroy_atacched_files
          destroy_files
          @item.destroy
  #        p "#preparation: #{@item.id} 削除."
          del_count += 1
        end
        Doclibrary::Doc.remove_connection
        dump "#{message}, 削除記事件数：#{del_count}"
      rescue => ex # エラー時
        if ex.message=~/Unknown database/
          dump "データベースが見つかりません。#{message}、エラーメッセージ：#{ex.message}"
        elsif ex.message=~/Mysql::Error: Table/
          dump "テーブルが見つかりません。#{message}、エラーメッセージ：#{ex.message}"
        else
          dump "エラーが発生しました。#{message}、エラーメッセージ：#{ex.message}"
        end
      end
    end
  end
  #-主なアクションの記述 END index ---------------------------------------------------

  #削除関連----------------------------------------------------------------------
  #削除条件
  def self.sql_where
    sql = Condition.new
    sql.and :parent_id, @item.id
    sql.and :title_id, @item.title_id
    return sql.where
  end
  #データベース登録ファイル削除
  def self.destroy_dbfiles
    item = db_alias(Doclibrary::DbFile)
    item.destroy_all(sql_where)
    Doclibrary::DbFile.remove_connection
  end
  #関連画像ファイル削除
  def self.destroy_image_files
    item = db_alias(Doclibrary::Image)

    image = item.new
    image.and :parent_id, @item.id
    image.and :title_id, @item.title_id
    image = image.find(:first)
    begin
      #画像ファイルを記事フォルダごと全削除
      image.image_delete_all(@img_path) if image
    rescue
    end

    #レコード全削除
    item.destroy_all(sql_where)
    Doclibrary::Image.remove_connection
  end
  #添付ファイルレコード削除
  def self.destroy_atacched_files
    item = db_alias(Doclibrary::File)

    files = item.find(:all, :order=> 'id', :conditions=>sql_where)
    files.each do |file|
      file.destroy
    end
    Doclibrary::File.remove_connection
  end
  #添付ファイルレコード削除
  def self.destroy_files
    item = db_alias(Doclibrary::DbFile)
    item.destroy_all(sql_where)
    Doclibrary::DbFile.remove_connection
  end
  #削除関連----------------------------------------------------------------------


  #インデックス関連----------------------------------------------------------------------
  def self.docs_add_index_script
    # 必要なインデックスを追加する
    dump "`書庫` : インデックス追加開始：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    item = Doclibrary::Control.new
    items = item.find(:all)

    items.each do |item|
      cnn = Doclibrary::Doc.establish_connection
      cnn.spec.config[:database] = item.dbname.to_s
      read = Doclibrary::Doc
      read.establish_connection(cnn.spec.config)
      unless read.blank?
        begin
          connect = read.connection()
          truncate_query = "ALTER TABLE `doclibrary_docs` ADD INDEX title_id(state(50),title_id,category1_id);"
          connect.execute(truncate_query)
          dump "`#{item.dbname.to_s}`.`書庫` : インデックス追加開始：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
        rescue
          dump "#{item.dbname.to_s}は既にindexを貼られていた、もしくはデータベースが存在していなかった、もしくはデータベース接続時にエラーが発生しました。：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
        end
      end
    end
    dump "`書庫` : インデックス追加終了：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  end

  def self.folder_add_index_script
    # 必要なインデックスを追加する
    dump "`書庫` : folder_index_追加開始：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    item = Doclibrary::Control.new
    items = item.find(:all)

    items.each do |item|
      cnn = Doclibrary::Doc.establish_connection
      cnn.spec.config[:database] = item.dbname.to_s
      read = Doclibrary::Doc
      read.establish_connection(cnn.spec.config)
      unless read.blank?
        begin
          connect = read.connection()

          truncate_query = "ALTER TABLE `doclibrary_folder_acls` ADD INDEX title_id(title_id);"
          connect.execute(truncate_query)
          truncate_query = "ALTER TABLE `doclibrary_folder_acls` ADD INDEX folder_id(folder_id);"
          connect.execute(truncate_query)
          truncate_query = "ALTER TABLE `doclibrary_folder_acls` ADD INDEX acl_section_code(acl_section_code);"
          connect.execute(truncate_query)
          truncate_query = "ALTER TABLE `doclibrary_folder_acls` ADD INDEX acl_user_code(acl_user_code);"
          connect.execute(truncate_query)

          truncate_query = "ALTER TABLE `doclibrary_folders` ADD INDEX title_id(title_id);"
          connect.execute(truncate_query)
          truncate_query = "ALTER TABLE `doclibrary_folders` ADD INDEX parent_id(parent_id);"
          connect.execute(truncate_query)
          truncate_query = "ALTER TABLE `doclibrary_folders` ADD INDEX sort_no(sort_no);"
          connect.execute(truncate_query)

          truncate_query = "ALTER TABLE `doclibrary_docs` ADD INDEX category1_id(category1_id);"
          connect.execute(truncate_query)
          truncate_query = "ALTER TABLE `doclibrary_docs` ADD INDEX title_id2(title_id);"
          connect.execute(truncate_query)
          dump "`#{item.dbname.to_s}`.`書庫` : folder_index_追加開始：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
        rescue
          dump "#{item.dbname.to_s}は既にindexを貼られていたか、データベースが存在していなかった、データベース接続時にエラーが発生するなどの理由でindexは作成できませんでした。確認をお願いします。：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
        end
      end
    end
    dump "`書庫` : folder_index_追加終了：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  end

  #doclibrary_controlsに設定されているdatabase接続先を参照する
  def self.db_alias(item)
    cnn = item.establish_connection
    #コントロールにdbnameが設定されているdbname名で接続する
    cnn.spec.config[:database] = @title.dbname.to_s
    Gwboard::CommonDb.establish_connection(cnn.spec.config)
    return item
  end
end
