module Concerns::Gw::Schedule::MeetingGuide
  extend ActiveSupport::Concern

  def guide_state_label
    self.class.guide_state_show(guide_state)
  end

  def guide_state_approved?
    guide_state == 2
  end

  def guide_state_unapproved?
    !guide_state_approved?
  end

  def approve_meeting_guide
    ret = true
    transaction do
      (get_parent_items + [self]).uniq.each do |item|
        item.guide_state = 2
        ret &&= item.save
      end
    end
    ret
  end

  def unapprove_meeting_guide
    ret = true
    transaction do
      (get_parent_items + [self]).uniq.each do |item|
        item.guide_state = 1
        ret &&= item.save
      end
    end
    ret
  end

  module ClassMethods
    def guide_state_select
      [['未承認', 1],['承認', 2]]
    end

    def guide_state_show(guide_state)
      guide_state_select.rassoc(guide_state).try(:first)
    end
  end
end
