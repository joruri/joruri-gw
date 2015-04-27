class UpdateTabKeysOnGwPrefSoumuMessages < ActiveRecord::Migration
  def change
    execute "update gw_pref_soumu_messages set tab_keys = 40" 
  end
end
