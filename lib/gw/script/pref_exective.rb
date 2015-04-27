class Gw::Script::PrefExective < System::Script::Base
  def self.state_all_off
    run do
      updates = {
        state: 'off', 
        updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"), 
        updated_user: '夜間クリア',
        updated_group: '情報システム課'
      }

      log "幹部ステータスoff処理" do
        upd = Gw::PrefExecutive.where(state: 'on').update_all(updates)
        log "#{upd} updated"
      end

      log "部課長ステータスoff処理" do
        upd = Gw::PrefDirector.where(state: 'on').update_all(updates)
        log "#{upd} updated"
      end
    end
  end
end
