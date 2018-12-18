class InsertDefaultValuesIntoGwPrefConfigs < ActiveRecord::Migration
  def up
    execute "insert into gw_pref_configs (state, option_type, name, options) values ('enabled', 'directors', 'admin', '部課長在庁表示は現在準備中です。')"
    execute "insert into gw_pref_configs (state, option_type, name, options) values ('enabled', 'executives', 'normal', '全庁幹部在庁表示は現在メンテナンス中です。')"
    execute "insert into gw_pref_configs (state, option_type, name, options) values ('enabled', 'directors2', 'admin', '係長・班長,1')"
  end

  def down
    execute "truncate table gw_pref_configs"
  end
end
