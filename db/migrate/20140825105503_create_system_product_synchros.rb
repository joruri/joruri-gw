class CreateSystemProductSynchros < ActiveRecord::Migration
  def change
    create_table :system_products do |t|
      t.string   :product_type
      t.string   :name
      t.timestamps
    end
    add_index :system_products, :product_type

    create_table :system_product_synchros do |t|
      t.references :product
      t.references :plan
      t.string     :state
      t.string     :version
      t.text       :remark_temp
      t.text       :remark_back
      t.text       :remark_sync
      t.timestamps
    end
    add_index :system_product_synchros, :product_id
    add_index :system_product_synchros, :plan_id
    add_index :system_product_synchros, :state

    create_table :system_product_synchro_plans do |t|
      t.string     :state
      t.datetime   :start_at
      t.text       :product_ids
      t.timestamps
    end
    add_index :system_product_synchro_plans, [:state, :start_at]
  end
end
