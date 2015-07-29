# encoding: utf-8
class Gw::Script::PrefExective
  def self.state_all_off
    updated_at     = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    dump "Gw::Script::PrefExective.state_all_off 在庁ステータスをoffにする自動処理、#{updated_at}に作業開始"
    updated_user   = '夜間クリア'
    updated_group  = '情報システム課'
    update = "state='off', updated_at='#{updated_at}', updated_user='#{updated_user}', updated_group='#{updated_group}'"
    dump "幹部ステータスoff処理"
    Gw::PrefExecutive.update_all(update, "state='on'")
    dump "部課長ステータスoff処理"
    Gw::PrefDirector.update_all(update, "state='on'")
    dump "Gw::Script::PrefExective.state_all_off 在庁ステータスをoffにする自動処理、#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}に作業終了"
  end
end
