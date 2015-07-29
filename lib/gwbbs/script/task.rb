# -*- encoding: utf-8 -*-
class Gwbbs::Script::Task

  def self.delete
    dump "#{self}, 掲示板id, DB名, 掲示板タイトル,削除件数, (処理開始)"
    item = Gwbbs::Itemdelete.new
    item.and :content_id, 0
    item = item.find(:first)
    dump "#{self}, 管理情報登録ない　終了." if item.blank?
    return if item.blank?
    dump "#{self}, 期間の設定がない　終了." if item.limit_date.blank?
    return if item.limit_date.blank?
    limit = get_limit_date(item.limit_date)
    return if limit.blank?

    make_target_record(limit)

    item = Gwbbs::Itemdelete.new
    item.and :content_id, 1
    items = item.find(:all)
    for rec_item in items
      destroy_record(rec_item.title_id, limit)
    end
    dump "#{self}, 掲示板期限切れ記事削除処理終了"
  end

  def self.get_limit_date(limit_date)
    limit = Date.today
    case limit_date
    when "1.day"
      limit = limit.ago(1.day)
    when "1.month"
      limit = limit.months_ago(1)
    when "3.months"
      limit = limit.months_ago(3)
    when "6.months"
      limit = limit.months_ago(6)
    when "9.months"
      limit = limit.months_ago(9)
    when "12.months"
      limit = limit.months_ago(12)
    when "15.months"
      limit = limit.months_ago(15)
    when "18.months"
      limit = limit.months_ago(18)
    when "24.months"
      limit = limit.months_ago(24)
    else
      limit = ''
    end
    return limit
  end
  #
  def self.make_target_record(limit_date)
    Gwbbs::Itemdelete.delete_all(["content_id = 1"])

    item = Gwbbs::Control
    item = item.new
    item.and :limit_date, 'use'
    item.order 'sort_no, id'
    items = item.find(:all)
    for @title in items
      begin
        count_item = db_alias(Gwbbs::Doc)
        sql = "SELECT COUNT(`id`) AS cnt FROM `gwbbs_docs`"
        sql += " WHERE `state` = 'public'"
        sql +=" AND '" + Time.now.strftime("%Y-%m-%d %H:%M:%S") + "' BETWEEN `able_date` AND `expiry_date` GROUP BY `title_id`;"
        public_count = count_item.count_by_sql(sql)

        sql = "SELECT COUNT(`id`) AS cnt FROM `gwbbs_docs`"
        sql += " WHERE `state` != 'preparation' AND `expiry_date` < '" + limit_date.strftime("%Y-%m-%d") + " 00:00:00'"
        delete_count = count_item.count_by_sql(sql)

        Gwbbs::Itemdelete.create({
          :content_id => 1 ,
          :title_id => @title.id ,
          :board_title => @title.title ,
          :board_state => @title.state == 'public' ? '公開中' : '非公開' ,
          :board_view_hide => @title.view_hide ? 'する' : 'しない',
          :board_sort_no => @title.sort_no ,
          :public_doc_count => public_count ,
          :void_doc_count => delete_count ,
          :dbname => @title.dbname ,
          :limit_date => limit_date
        })
      rescue => ex
#        dump "#{self} : 異常終了 : #{ex.message}"
      end
      Gwbbs::Doc.remove_connection
    end
  end

  def self.destroy_record(id, limit)
    @title = Gwbbs::Control.find_by_id(id)
    unless @title.blank?
      @img_path = "public/_common/modules/#{@title.system_name}/"   #画像path指定
      item = db_alias(Gwbbs::Doc)
      doc_item = item.new
      doc_item.and :state, 'preparation'
      doc_item.and :created_at, '<' , Date.yesterday.strftime("%Y-%m-%d") + ' 00:00:00'
      @items = doc_item.find(:all)
      for @item in @items
        destroy_comments
        #destroy_image_files
        destroy_atacched_files
        destroy_files
        @item.destroy
      end
      doc_item = item.new
      doc_item.and :state, '!=' ,'preparation'
      doc_item.and :expiry_date, '<' , limit.strftime("%Y-%m-%d") + ' 00:00:00'
      @items = doc_item.find(:all)
      del_count = 0
      for @item in @items
        destroy_comments
        #destroy_image_files
        destroy_atacched_files
        destroy_files
        @item.destroy
        del_count += 1
      end
      Gwbbs::Doc.remove_connection
      dump "#{self}, #{@title.id}, #{@title.dbname}, #{@title.title},#{del_count}"
    end
  end

  def self.sql_where
    sql = Condition.new
    sql.and :parent_id, @item.id
    sql.and :title_id, @item.title_id
    return sql.where
  end

  def self.destroy_comments
    item = db_alias(Gwbbs::Comment)
    item.destroy_all(sql_where)
    Gwbbs::Comment.remove_connection
  end

  def self.destroy_image_files
    item = db_alias(Gwbbs::Image)

    image = item.new
    image.and :parent_id, @item.id
    image.and :title_id, @item.title_id
    image = image.find(:first)
    begin
      image.image_delete_all(@img_path) if image
    rescue
    end

    item.destroy_all(sql_where)
    Gwbbs::Image.remove_connection
  end

  def self.destroy_atacched_files
    item = db_alias(Gwbbs::File)
    item.destroy_all(sql_where)
    Gwbbs::File.remove_connection
  end

  def self.destroy_files
    item = db_alias(Gwbbs::DbFile)
    item.destroy_all(sql_where)
    Gwbbs::DbFile.remove_connection
  end

  def self.db_alias(item)
    cnn = item.establish_connection
    cnn.spec.config[:database] = @title.dbname.to_s
    Gwboard::CommonDb.establish_connection(cnn.spec.config)
    return item
  end

  def self.preparation_delete
    dump "#{self}, 不要データ削除処理開始：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    item = Gwbbs::Control.new
    items = item.find(:all)
    for rec_item in items
      preparation_destroy_record(rec_item.id)
    end
    dump "#{self}, 不要データ削除処理終了：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  end

  def self.preparation_destroy_record(id)
    @title = Gwbbs::Control.find_by_id(id)
    del_count = 0
    message = "データベース名：#{@title.dbname}, 掲示板名：#{@title.title}"
    unless @title.blank?
      begin
        @img_path = "public/_common/modules/#{@title.system_name}/"
        item = db_alias(Gwbbs::Doc)
        limit = preparation_get_limit_date
        doc_item = item.new
        doc_item.and :state, 'preparation'
        doc_item.and :created_at, '<', "#{limit.strftime("%Y-%m-%d")} 00:00:00"
        @items = doc_item.find(:all)
        for @item in @items
          destroy_files
          #destroy_image_files
          preparation_destroy_atacched_files
          @item.destroy
          del_count += 1
        end
        Gwbbs::Doc.remove_connection
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
  def self.preparation_get_limit_date
    limit = Date.today
    limit.ago(1.day)
  end
  def self.preparation_destroy_atacched_files
    item = db_alias(Gwbbs::File)
    files = item.find(:all, :order=> 'id', :conditions=>sql_where)
    files.each do |file|
      file.destroy
    end
    Gwbbs::File.remove_connection
  end

end
