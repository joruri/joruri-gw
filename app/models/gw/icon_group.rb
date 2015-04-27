class Gw::IconGroup < Gw::Database
  include System::Model::Base
	include System::Model::Base::Content

  has_many :gw_icons
end
