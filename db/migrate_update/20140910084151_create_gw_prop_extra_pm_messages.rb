class CreateGwPropExtraPmMessages < ActiveRecord::Migration
  def change
    create_table :gw_prop_extra_pm_messages do |t|
      t.text :body
      t.integer :sort_no
      t.integer :state
      t.integer :prop_class_id
      t.timestamps
    end
  end
end
