class Gw::PropMeetingroomImage < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gw::Model::File::PropImage

  belongs_to :meetingroom, :foreign_key => :parent_id, :class_name => 'Gw::PropMeetingroom'
end
