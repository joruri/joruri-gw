class Gw::Script::Memo < System::Script::Base
  def self.delete
    run do
      settings = Gw::Property::MemoAdminDelete.first_or_new.memos
      return if settings['read_memos_admin_delete'].blank?
      return if settings['unread_memos_admin_delete'].blank?

      log "既読メモ削除処理" do
        del1 = delete_read_memo(settings['read_memos_admin_delete'])
        log "#{del1} deleted"
      end

      log "未読メモ削除処理" do
        del2 = delete_unread_memo(settings['unread_memos_admin_delete'])
        log "#{del2} deleted"
      end

      log "テーブル最適化" do
        Gw::Memo.optimize_and_analyze_table
        Gw::MemoUser.optimize_and_analyze_table
      end
    end
  end

  private

  def self.setting_value_to_days(value)
    case value.to_i
    when 1
      5
    when 2
      10
    when 3
      20
    when 4
      30
    else
      30
    end
  end

  def self.delete_read_memo(value)
    date = Date.today - setting_value_to_days(value)
    del = 0
    Gw::Memo.where(is_finished: 1).created_before(date).find_each do |memo|
      Gw::Memo.transaction do
        if memo.delete
          memo.memo_users.delete_all
          del += 1
        end
      end
    end
    del
  end

  def self.delete_unread_memo(value)
    date = Date.today - setting_value_to_days(value)
    del = 0
    Gw::Memo.where('is_finished is null or is_finished = 0').created_before(date).find_each do |memo|
      Gw::Memo.transaction do
        if memo.delete
          memo.memo_users.delete_all
          del += 1
        end
      end
    end
    del
  end
end
