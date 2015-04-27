class Gw::PropRentcarImage < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gw::Model::File::PropImage

  belongs_to :rentcar, :foreign_key => :parent_id, :class_name => 'Gw::PropRentcar'
end
