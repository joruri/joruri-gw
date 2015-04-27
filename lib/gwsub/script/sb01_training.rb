class Gwsub::Script::Sb01_training < System::Script::Base

  def self.delete_abandoned_files(hours = 24)
    run do
      limit_date = limit_date_for_preparation

      log "研修申込不要添付ファイル削除処理: #{I18n.l(limit_date)} 以前を削除" do
        del = 0
        Gwsub::Sb01TrainingFile.get_abandoned_files(limit_date).find_each do |item|
          if item.delete_record
            del += 1
          end
        end
        log "#{del} deleted"
      end
    end
  end
end
