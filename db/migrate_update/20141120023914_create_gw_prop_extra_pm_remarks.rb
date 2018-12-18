class CreateGwPropExtraPmRemarks < ActiveRecord::Migration
  def change
    create_table :gw_prop_extra_pm_remarks do |t|
      t.integer :prop_class_id
      t.string  :state
      t.integer :sort_no
      t.string  :title
      t.string  :url
      t.timestamps
    end
  end
end
