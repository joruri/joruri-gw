class InsertDefaultValuesIntoGwsubCapacityunitsets < ActiveRecord::Migration
  def up
    execute "insert into gwsub_capacityunitsets (code_int, code, name) values (1, 1, 'KB')"
    execute "insert into gwsub_capacityunitsets (code_int, code, name) values (2, 2, 'MB')"
    execute "insert into gwsub_capacityunitsets (code_int, code, name) values (3, 3, 'GB')"
    execute "insert into gwsub_capacityunitsets (code_int, code, name) values (4, 4, 'TB')"
  end
  def down
  end
end
