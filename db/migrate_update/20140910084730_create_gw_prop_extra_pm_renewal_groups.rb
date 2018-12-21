class CreateGwPropExtraPmRenewalGroups < ActiveRecord::Migration
  def change
    create_table :gw_prop_extra_pm_renewal_groups do |t|
      t.integer :present_group_id
      t.string :present_group_code
      t.integer :incoming_group_id
      t.string :ncoming_group_code, :limit => 255
      t.text :incoming_group_name
      t.datetime :modified_at
      t.timestamps
    end
  end
end
