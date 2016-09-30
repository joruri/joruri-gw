class Gw::ScheduleFile < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content
  include Gw::Model::File::Memo

  #belongs_to :parent, :foreign_key => :parent_id, :class_name => 'Gw::Schedule'
end
