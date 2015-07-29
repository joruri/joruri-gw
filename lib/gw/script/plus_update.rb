# encoding: utf-8
module Gw::Script::PlusUpdate
  def self.destroy_reminders
    title = "Gw-Plus　リマインダー連携"
    s_method = "destroy_reminders"
    dump "#{self}.#{s_method}, #{title}, 過去のリマインダーデータ削除処理開始：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    date_str = Time.now.last_month.strftime('%Y-%m-%d 23:59:59')
    dump "#{date_str}以前のリマインダーを削除"
    Gw::PlusUpdate.destroy_all("doc_updated_at < '#{date_str}'")
    dump "#{self}.#{s_method}, #{title}, 過去のリマインダーデータ削除処理終了：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  end

end
