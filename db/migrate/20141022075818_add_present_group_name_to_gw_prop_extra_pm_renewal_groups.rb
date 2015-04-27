class AddPresentGroupNameToGwPropExtraPmRenewalGroups < ActiveRecord::Migration
  def change
    add_column :gw_prop_extra_pm_renewal_groups, :present_group_name, :text
    remove_column :gw_prop_extra_pm_renewal_groups, :ncoming_group_code
    add_column :gw_prop_extra_pm_renewal_groups, :incoming_group_code, :string, :limit => 255
  end
end
