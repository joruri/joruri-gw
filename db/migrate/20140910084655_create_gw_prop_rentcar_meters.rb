class CreateGwPropRentcarMeters < ActiveRecord::Migration
  def change
    create_table :gw_prop_rentcar_meters do |t|
      t.integer :parent_id
      t.integer :travelled_km
      t.timestamps
    end
  end
end
