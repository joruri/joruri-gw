class CreateGwPropRentcars < ActiveRecord::Migration
  def change
    create_table :gw_prop_rentcars do |t|
      t.integer :sort_no
      t.string :car_model, :limit=>255
      t.string :name, :limit=>255
      t.integer :type_id
      t.integer :delete_state
      t.integer :reserved_state
      t.string :register_no, :limit=>255
      t.string :exhaust, :limit=>255
      t.integer :year_type
      t.text :comment
      t.string :extra_flag
      t.text :extra_data
      t.string :gid, :limit=>255
      t.string :gname, :limit=>255
      t.integer :travelled_km
      t.timestamps
    end
  end
end
