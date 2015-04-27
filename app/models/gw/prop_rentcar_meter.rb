class Gw::PropRentcarMeter < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :rentcar, :foreign_key => :parent_id, :class_name => 'Gw::PropRentcar'
end
