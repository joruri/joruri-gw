class UpdateSortNoWithinIntegerRangeOnGwPropOthers < ActiveRecord::Migration
  def up
    execute "update gw_prop_others set sort_no = '638000001' where sort_no = '63800000001'"
    execute "update gw_prop_others set sort_no = '638000002' where sort_no = '63800000002'"
    execute "update gw_prop_others set sort_no = '638000003' where sort_no = '63800000003'"
  end
  def down
  end
end
