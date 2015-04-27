class Gw::PropExtraPmRentcarUnitPrice < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  def self.get_unit_price(d = Date.today)
    item = self.where('end_at is null').first
    return item.unit_price if !item.blank?
    d_s = Gw.date_str(d)
    item = self.where("start_at <= #{d_s} and end_at >= #{d_s}").first
    return item.unit_price if !item.blank?
    nil
  end
end
