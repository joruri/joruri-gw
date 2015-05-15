class Gwworkflow::Script::Task < System::Script::Base

  def self.delete
    run do
      title = Gwworkflow::Control.first
      log "削除処理が無効" and next if title.blank? || title.limit_date != 'use'

      item = Gwworkflow::Itemdelete.where(content_id: 0).first
      log "管理情報の登録なし" and next if item.blank?

      limit = eval(item.limit_date.to_s).try(:ago)
      log "管理情報の期間設定が無効: #{item.limit_date}" and next if limit.blank?

      log "ワークフロー期限切れデータ削除処理: #{I18n.l(limit)} 以前を削除" do
        del = Gwworkflow::Doc.where(["expired_at < ?", limit]).destroy_all.size
        log "#{del} deleted"
      end
    end
  end

  def self.preparation_delete
    run do
      log "ワークフロー不要データ削除処理: #{I18n.l(limit_date_for_preparation)} 以前を削除" do
        del = Gwworkflow::Doc.created_before(limit_date_for_preparation).where(state: 'quantum').destroy_all.size
        log "#{del} deleted"
      end
    end
  end
end
