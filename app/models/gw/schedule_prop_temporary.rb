class Gw::SchedulePropTemporary < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  belongs_to :prop, :polymorphic => true

  def other_related?
    self.prop_type == 'Gw::PropOther'
  end

  def is_special_meeting_room?
    self.prop_type.in?(["Gw::PropMeetingroom"]) && self.prop.type_id == 4
  end


end
