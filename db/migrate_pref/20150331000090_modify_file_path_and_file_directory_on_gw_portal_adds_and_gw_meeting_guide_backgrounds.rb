class ModifyFilePathAndFileDirectoryOnGwPortalAddsAndGwMeetingGuideBackgrounds < ActiveRecord::Migration
  def up
    execute %|update gw_portal_adds set file_path = replace(file_path, '/_common/themes/gw/files/portal/adds/', '/_attaches/gw/portal_adds/')|
    execute %|update gw_portal_adds set file_directory = replace(file_directory, '/_common/themes/gw/files/portal/adds/', '/_attaches/gw/portal_adds/')|
    execute %|update gw_meeting_guide_backgrounds set file_path = replace(file_path, '/_common/themes/gw/files/meetings/', '/_attaches/meeting_guides/')|
    execute %|update gw_meeting_guide_backgrounds set file_directory = replace(file_directory, '/_common/themes/gw/files/meetings/', '/_attaches/meeting_guides/')|
  end
  def down
  end
end
