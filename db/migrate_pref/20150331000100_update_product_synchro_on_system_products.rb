class UpdateProductSynchroOnSystemProducts < ActiveRecord::Migration
  def up
    execute "update system_products set product_synchro = 1 where product_type in ('gw', 'mail', 'hcs')"
  end
  def down
  end
end
