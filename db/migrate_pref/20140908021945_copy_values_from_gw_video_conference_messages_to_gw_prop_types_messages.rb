class CopyValuesFromGwVideoConferenceMessagesToGwPropTypesMessages < ActiveRecord::Migration
  def change
    execute "insert into gw_prop_types_messages (state, sort_no, body, type_id) select state, sort_no, body, 400 from gw_video_conference_messages;"
  end
end
