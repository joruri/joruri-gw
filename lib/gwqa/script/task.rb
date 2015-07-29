# -*- encoding: utf-8 -*-
#######################################################################
#
#
#######################################################################

class Gwqa::Script::Task

  def self.preparation_delete
    dump "#{self}, 不要データ削除処理開始：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    item = Gwqa::Control.new
    items = item.find(:all)
    for rec_item in items
      destroy_record(rec_item.id)
    end
    dump "#{self}, 不要データ削除処理終了：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  end

  def self.destroy_record(id)
    @title = Gwqa::Control.find_by_id(id)
    message = "データベース名：#{@title.dbname}, Q&A名：#{@title.title}"

    del_count = 0
    unless @title.blank?
#      p "#{@title.dbname}処理開始."
      begin
        @img_path = "public/_common/modules/#{@title.system_name}/"   #画像path指定
        item = db_alias(Gwqa::Doc)
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
        Gwqa::Doc.remove_connection
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
  #添付ファイル管理レコード削除
  def self.destroy_dbfiles
    item = db_alias(Gwqa::DbFile)
    item.destroy_all(sql_where)
    Gwqa::DbFile.remove_connection
  end
  #関連画像ファイル削除
  def self.destroy_image_files
    item = db_alias(Gwqa::Image)

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
    Gwqa::Image.remove_connection
  end
  #添付ファイル管理レコード削除
  def self.destroy_atacched_files
    item = db_alias(Gwqa::File)
    files = item.find(:all, :order=> 'id', :conditions=>sql_where)
    files.each do |file|
      file.destroy
    end
    Gwqa::File.remove_connection
  end
  #添付ファイルレコード削除
  def self.destroy_files
    item = db_alias(Gwqa::DbFile)
    item.destroy_all(sql_where)
    Gwqa::DbFile.remove_connection
  end
  #削除関連----------------------------------------------------------------------


  #gwqa_controlsに設定されているdatabase接続先を参照する
  def self.db_alias(item)
    cnn = item.establish_connection
    #コントロールにdbnameが設定されているdbname名で接続する
    cnn.spec.config[:database] = @title.dbname.to_s
    Gwboard::CommonDb.establish_connection(cnn.spec.config)
    return item
  end
end
