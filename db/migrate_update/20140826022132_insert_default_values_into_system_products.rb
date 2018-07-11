class InsertDefaultValuesIntoSystemProducts < ActiveRecord::Migration
  def change
    execute "insert into system_products (product_type, name) values ('gw', 'Joruri Gw')"
  end
end
