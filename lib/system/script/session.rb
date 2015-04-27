class System::Script::Session < System::Script::Base
  def self.delete_expired_sessions
    run do
      log "セッション期限切れデータ削除処理" do
        count = System::Session.delete_expired_sessions
        log "#{count} deleted"
      end

      log "テーブル最適化" do
        System::Session.optimize_and_analyze_table
      end
    end
  end
end
