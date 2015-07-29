class Gwbbs::Script::Init
  def self.init_update
    titles = Gwbbs::Control.find(:all)
    for @title in titles
      begin
      sql = "SELECT SUM(LENGTH(`body`)) AS total_size FROM `gwbbs_docs` WHERE title_id = #{@title.id} GROUP BY title_id"
      item = db_alias(Gwbbs::Doc)
      item = item.find_by_sql(sql)
      total_size = 0
      total_size = item[0].total_size unless item[0].total_size.blank? unless item.blank?
      @title.doc_body_size_currently  = total_size
      @title.save
      rescue
        p "nodb:#{@title.dbname}"
      end
    end
  end

  def self.db_alias(item)
    cnn = item.establish_connection
    cnn.spec.config[:database] = @title.dbname.to_s
    Gwboard::CommonDb.establish_connection(cnn.spec.config)
    return item
  end
end
