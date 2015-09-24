module Concerns::Gw::Schedule::Prop
  extend ActiveSupport::Concern


  def meetingroom_related?
    self.prop_type == 'Gw::PropMeetingroom'
  end

  def rentcar_related?
    self.prop_type == 'Gw::PropRentcar'
  end

  def other_related?
    self.prop_type == 'Gw::PropOther'
  end

  def is_special_meeting_room?
    self.prop_type.in?(["Gw::PropMeetingroom"]) && self.prop.type_id == 4
  end

end
