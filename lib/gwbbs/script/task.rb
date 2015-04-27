class Gwbbs::Script::Task < System::Script::Base

  def self.delete
    run do
      itemd = Gwbbs::Itemdelete.where(content_id: 0).first
      log "管理情報の登録なし" and next if itemd.blank?

      limit = eval(itemd.limit_date.to_s).try(:ago)
      log "管理情報の期間設定が無効: #{itemd.limit_date}" and next if limit.blank?

      log "掲示板期限切れデータ削除処理: #{I18n.l(limit)} 以前を削除" do
        Gwbbs::Control.where(limit_date: 'use').find_each do |title|
          log "#{title.class}: id: #{title.id}, title: #{title.title}"
          del = destroy_record(title, limit)
          log "#{del} deleted"
        end
      end
    end
  end

  def self.preparation_delete
    run do
      log "掲示板不要データ削除処理: #{I18n.l(limit_date_for_preparation)} 以前を削除" do
        Gwbbs::Control.find_each do |title|
          log "#{title.class}: id: #{title.id}, title: #{title.title}"
          del = preparation_destroy_record(title)
          log "#{del} deleted"
        end
      end
    end
  end

  private

  def self.destroy_record(title, limit)
    del = 0
    title.docs.where(['expiry_date < ?', limit]).find_each do |doc|
      if doc.destroy
        del += 1
      end
    end
    del
  end

  def self.preparation_destroy_record(title)
    del = 0
    title.docs.where(state: 'preparation').created_before(limit_date_for_preparation).find_each do |doc|
      if doc.destroy
        del += 1
      end
    end
    del
  end
end
