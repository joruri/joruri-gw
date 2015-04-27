class Gw::Script::ReminderExternal < System::Script::Base
  def self.delete
    run do
      log "外部連携リマインダー削除処理" do
        del = Gw::ReminderExternal.where.not(deleted_at: nil).delete_all
        log "#{del} deleted"
      end

      log "テーブル最適化" do
        Gw::ReminderExternal.optimize_and_analyze_table
      end
    end
  end
end
