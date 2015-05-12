class Gw::Icon < Gw::Database
  include System::Model::Base
	include System::Model::Base::Content

  belongs_to :icon_group, :foreign_key => :icon_gid, :class_name => 'Gw::IconGroup'
end
