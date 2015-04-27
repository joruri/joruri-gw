class Questionnaire::Script::Task < System::Script::Base

  def self.delete
    run do
      item = Questionnaire::Itemdelete.where(content_id: 0).first
      log "管理情報の登録なし" and next if item.blank?

      limit = eval(item.limit_date.to_s).try(:ago)
      log "管理情報の期間設定が無効: #{item.limit_date}" and next if limit.blank?

      log "アンケート集計期限切れデータ削除処理: #{I18n.l(limit)} 以前を削除" do
        del = destroy_record(limit)
        log "#{del} deleted"
      end
    end
  end

  private

  def self.destroy_record(limit)
    del = 0
    Questionnaire::Base.where(["expiry_date < ?", limit]).find_each do |item|
      if item.destroy
        del += 1
      end
    end
    del
  end
end
