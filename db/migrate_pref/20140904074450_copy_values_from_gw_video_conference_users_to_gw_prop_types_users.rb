class CopyValuesFromGwVideoConferenceUsersToGwPropTypesUsers < ActiveRecord::Migration
  def change
    execute "insert into gw_prop_types_users (user_id, user_name, type_id) select user_id, user_name, 400 from gw_video_conference_users;"
  end
end
