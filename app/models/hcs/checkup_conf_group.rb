class Hcs::CheckupConfGroup < Hcs::CheckupDatabase
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :conf, :class_name => 'Hcs::CheckupConfSetting', :foreign_key => :conf_id
end
