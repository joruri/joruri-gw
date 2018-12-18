class AddWidthAndHeightToGwMeetingGuideBackgrounds < ActiveRecord::Migration
  def change
    add_column :gw_meeting_guide_backgrounds, :width, :integer, after: :content_type
    add_column :gw_meeting_guide_backgrounds, :height, :integer, after: :width
  end
end
