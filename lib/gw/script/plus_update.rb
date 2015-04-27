class Gw::Script::PlusUpdate < System::Script::Base
  def self.destroy_reminders
    run do
      date_str = Time.now.last_month
      log "過去のリマインダーデータ削除処理: #{I18n.l(date_str)} 以前を削除" do
        dels = Gw::PlusUpdate.where(["doc_updated_at < ?", date_str]).destroy_all
        log "#{dels.size} deleted"
      end
    end
  end
end
