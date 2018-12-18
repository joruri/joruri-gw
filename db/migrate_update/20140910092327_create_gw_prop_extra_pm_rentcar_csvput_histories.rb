class CreateGwPropExtraPmRentcarCsvputHistories < ActiveRecord::Migration
  def change
    create_table :gw_prop_extra_pm_rentcar_csvput_histories do |t|
      t.datetime :start_at
      t.datetime :end_at
      t.text :updated_user
      t.text :updated_group
      t.text :created_user
      t.text :created_group
      t.timestamps
    end
  end
end
