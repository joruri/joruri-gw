class UpdateProductSynchroValuesAndSoOnOnSystemProducts < ActiveRecord::Migration
  def up
    execute "update system_products set product_synchro = 1 where product_type = 'gw'"
    execute "insert into system_products (product_type, name, sort_no, product_synchro, sso) values ('mail', 'Joruri Mail', 10, 0, 1)"
    execute "insert into system_products (product_type, name, sort_no, product_synchro, sso) values ('plus', 'Joruri Plus+', 20, 0, 0)"
    execute "insert into system_products (product_type, name, sort_no, product_synchro, sso) values ('video', 'Joruri Video', 30, 0, 0)"
    execute "insert into system_products (product_type, name, sort_no, product_synchro, sso) values ('maps', 'Joruri Maps', 40, 0, 0)"
  end
  def down
  end
end
