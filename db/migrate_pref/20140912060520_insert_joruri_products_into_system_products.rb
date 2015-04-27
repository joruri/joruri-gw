class InsertJoruriProductsIntoSystemProducts < ActiveRecord::Migration
  def change
    execute "insert into system_products (product_type, name) values ('cms', 'Joruri CMS')"
    execute "insert into system_products (product_type, name) values ('plus', 'Joruri Plus+')"
    execute "insert into system_products (product_type, name) values ('video', 'Joruri Video')"
    execute "insert into system_products (product_type, name) values ('desktop', 'Joruri Desktop')"
    execute "insert into system_products (product_type, name) values ('maps', 'Joruri Maps')"
    execute "update system_products set sso = 1 where product_type in ('mail', 'hcs', 'plus', 'video', 'maps')"
  end
end
