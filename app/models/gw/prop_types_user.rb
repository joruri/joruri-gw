class Gw::PropTypesUser < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :user, :foreign_key => :user_id, :class_name => 'System::User'
  belongs_to :prop_type, :foreign_key => :type_id, :class_name => 'Gw::PropType'
end
