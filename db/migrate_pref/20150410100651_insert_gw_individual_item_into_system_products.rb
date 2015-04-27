class InsertGwIndividualItemIntoSystemProducts < ActiveRecord::Migration
  def change
    ind_sso_url = Joruri.config.application['migrate.ind_sso_url']
    sql = "INSERT INTO `system_products` (`product_type`, `name`, `sort_no`, `product_synchro`, `sso`, `sso_url`, `sso_url_mobile`) VALUES"
    sql += " ('gw_ind', 'Joruri Gw IndividualActivity',  999, 0, 1, '#{ind_sso_url}', '');"
    execute(sql)
  end
end
