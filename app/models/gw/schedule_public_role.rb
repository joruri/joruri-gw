# encoding: utf-8
class Gw::SchedulePublicRole < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :schedule, :foreign_key => :schedule_id, :class_name => 'Gw::Schedule'
  belongs_to :user, :foreign_key => :uid, :class_name => 'System::User'
  belongs_to :group, :foreign_key => :uid, :class_name => 'System::Group'

end
