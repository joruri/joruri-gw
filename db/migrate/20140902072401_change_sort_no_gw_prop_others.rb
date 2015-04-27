class ChangeSortNoGwPropOthers < ActiveRecord::Migration
  def change
    change_column(:gw_prop_others, :sort_no, :integer)
  end
end
