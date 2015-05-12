class Gw::IconGroup < Gw::Database
  include System::Model::Base
	include System::Model::Base::Content

  has_many :icons, :foreign_key => :icon_gid, :class_name => 'Gw::Icon'
end
