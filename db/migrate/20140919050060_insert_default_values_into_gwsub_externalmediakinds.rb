class InsertDefaultValuesIntoGwsubExternalmediakinds < ActiveRecord::Migration
  def up
    execute "insert into gwsub_externalmediakinds (sort_order_int, sort_order, kind, name) values (1, 1, 'CD', 'CD')"
    execute "insert into gwsub_externalmediakinds (sort_order_int, sort_order, kind, name) values (2, 2, 'DVD', 'DVD')"
    execute "insert into gwsub_externalmediakinds (sort_order_int, sort_order, kind, name) values (3, 3, 'BD', 'BD')"
    execute "insert into gwsub_externalmediakinds (sort_order_int, sort_order, kind, name) values (4, 4, 'FD', 'FD')"
    execute "insert into gwsub_externalmediakinds (sort_order_int, sort_order, kind, name) values (5, 5, 'HDD', 'HDD')"
    execute "insert into gwsub_externalmediakinds (sort_order_int, sort_order, kind, name) values (6, 6, 'MO', 'MO')"
    execute "insert into gwsub_externalmediakinds (sort_order_int, sort_order, kind, name) values (7, 7, 'DAT', 'DAT')"
    execute "insert into gwsub_externalmediakinds (sort_order_int, sort_order, kind, name) values (8, 8, 'USB', 'USB')"
    execute "insert into gwsub_externalmediakinds (sort_order_int, sort_order, kind, name) values (9, 9, 'SD', 'SD')"
    execute "insert into gwsub_externalmediakinds (sort_order_int, sort_order, kind, name) values (10, 10, 'SM', 'SM')"
    execute "insert into gwsub_externalmediakinds (sort_order_int, sort_order, kind, name) values (11, 11, 'CF', 'CF')"
  end
  def down
  end
end
