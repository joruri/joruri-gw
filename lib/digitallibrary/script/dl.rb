# -*- encoding: utf-8 -*-
#######################################################################
#添付ファイルのリンクをコントローラ経由のダウンロード形式へ変更する
#Filesテーブルから画像以外のレコードを抽出
#リンク情報を元に、親記事レコード中の記事情報リンクを書き換える
#######################################################################

class Digitallibrary::Script::Dl

  def self.change
    item = Digitallibrary::Control.new
    item.and :upload_system, 1
    items = item.find(:all)
    p "対象掲示板件数: #{items.size}"
    for @title in items
      p "変換開始:#{Time.now}, #{@title.title}"
      begin
      item = db_alias(Digitallibrary::File)
      item = item.new
      item.and :unid, 2
      files = item.find(:all)
      rec_cnt = 0
      for file in files
        rec_cnt += 1
        item = db_alias(Digitallibrary::Doc)
        item = item.new
        item.and :id, file.parent_id
        doc = item.find(:first)
        unless doc.blank?
          str = sprintf("%08d",file.id)
          str = "#{str[0..3]}/#{str[4..7]}"
          parent_name = Util::CheckDigit.check(format('%07d', file.parent_id))
          bef_file_name = "#{file.file_uri(@title.system_name)}"
          aft_file_name = "/_admin/attaches/digitallibrary/#{sprintf('%06d',file.title_id)}/#{parent_name}/#{str}/#{URI.encode(file.filename)}"
          begin
          sql = %Q[UPDATE `digitallibrary_docs` SET body=REPLACE(body,'#{bef_file_name}', '#{aft_file_name}') WHERE id=#{file.parent_id};]
          doc._execute_sql(sql)
          rescue
          p "SQLのエラー:#{sql}"
          end

          file.content_id = 3
          file.db_file_id = 0
          file.save
        end
        Digitallibrary::Doc.remove_connection
      end
      Digitallibrary::File.remove_connection
      @title.upload_system = 3
      @title.save
      p "変換終了:#{Time.now}, #{@title.title}, #{rec_cnt}"
      rescue
        p "データベースが存在しない:#{@title.dbname}"
      end
    end
  end

  #digitallibrary_controlsに設定されているdatabase接続先を参照する
  def self.db_alias(item)
    cnn = item.establish_connection
    #コントロールにdbnameが設定されているdbname名で接続する
    cnn.spec.config[:database] = @title.dbname.to_s
    Gwboard::CommonDb.establish_connection(cnn.spec.config)
    return item
  end
end