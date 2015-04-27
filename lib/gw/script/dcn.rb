class Gw::Script::Dcn < System::Script::Base
  def self.delete
    run do
      log "電子決裁不要データ削除処理" do
        del = Gw::DcnApproval.where(:state => 2).delete_all
        log "#{del} deleted"
      end

      log "テーブル最適化" do
        Gw::DcnApproval.optimize_and_analyze_table
      end
    end
  end
end
