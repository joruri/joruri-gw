class InsertDefaultUnitIntoGwPropExtraPmRentcarUnitPrices < ActiveRecord::Migration
  def change
    Gw::PropExtraPmRentcarUnitPrice.first_or_create(:unit_price=>40, :start_at => Time.now)
  end
end
