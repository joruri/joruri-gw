# -*- encoding: utf-8 -*-
#######################################################################
#
#
#######################################################################

class Questionnaire::Script::Task


  #夜間記事削除
  def self.delete
    dump "#{self}, アンケート集計システム (処理開始)"
    #管理情報取得
    item = Questionnaire::Itemdelete.new
    item.and :content_id, 0
    item = item.find(:first)
    dump "#{self}, 管理情報登録ない　終了." if item.blank?
    return if item.blank?
    dump "#{self}, 期間の設定がない　終了." if item.limit_date.blank?
    return if item.limit_date.blank?
    #削除対象日付取得
    limit = self.get_limit_date(item.limit_date)
    dump "#{self}, 期間の設定が異常です。データ：#{item.limit_date}　終了." if limit.blank?
    return if limit.blank?

    self.destroy_record(limit)

    dump "#{self}, アンケート集計システム記事削除(処理終了)"

  end

  #削除対象日を計算する
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
    dump "削除基準日：#{limit}"
    return limit
  end


  def self.destroy_record(limit)
    sql = Condition.new
    #期限切れ
    sql.or {|d|
      d.and :expiry_date, '<' , limit.strftime("%Y-%m-%d") + ' 00:00:00'
    }
    #設問記事編集中止の時
    sql.or {|d|
      d.and :state, 'preparation'
    }
    item = Questionnaire::Base.new
    items = item.find(:all, :conditions=>sql.where)
      del_count = 0
    for @title in items
      del_count += 1
      begin
        @title.destroy
      rescue => ex
        dump "#{self} : エラー発生 : #{ex.message}"
      end
    end
    dump "#{self}, アンケート集計システム削除件数: #{del_count}"
  end

end
