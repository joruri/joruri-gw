# encoding: utf-8
class Gwworkflow::Script::Task

  def self.delete
    dump "#{self}, 稟議書id, DB名, 稟議書タイトル,削除件数, (処理開始) at #{DateTime.now.to_s}"
    item = Gwworkflow::Itemdelete.new
    item.and :content_id, 0
    item = item.find(:first)
    dump "#{self}, 管理情報登録ない　終了." if item.blank?
    return if item.blank?
    dump "#{self}, 期間の設定がない　終了." if item.limit_date.blank?
    return if item.limit_date.blank?
    limit = get_limit_date(item.limit_date)
    return if limit.blank?

    destroy_record(limit)
    dump "#{self}, 稟議書期限切れ記事削除処理終了"
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

  def self.destroy_record(limit)
    @title = Gwworkflow::Control.find_by_id(1)
    dump @title.present?
    if @title.present? && @title.limit_date == 'use'
      @img_path = "public/_attaches/#{@title.system_name}/"
      item = Gwworkflow::Doc
      doc_item = item.new
      doc_item.and :expired_date, '<' , limit.strftime("%Y-%m-%d") + ' 00:00:00'
      @items = doc_item.find(:all)
      del_count = 0
      for @item in @items
        destroy_atacched_files
        @item.destroy
        del_count += 1
      end
      dump "#{self}, #{@title.id}, #{@title.dbname}, #{@title.title},#{del_count}"
    end
  end

  def self.sql_where
    sql = Condition.new
    sql.and :parent_id, @item.id
    return sql.where
  end

  def self.destroy_atacched_files
    item = Gwworkflow::File
    files = item.find(:all, :order=> 'id', :conditions=>sql_where)
    files.each do |file|
      file.destroy
    end
  end

end
