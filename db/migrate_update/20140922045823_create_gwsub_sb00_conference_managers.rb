class CreateGwsubSb00ConferenceManagers < ActiveRecord::Migration
  def change
    create_table :gwsub_sb00_conference_managers do |t|
      t.text   :controler
      t.text   :controler_title
      t.text   :memo_str
      t.integer   :fyear_id
      t.text   :fyear_markjp
      t.integer   :group_id
      t.text   :group_code
      t.text   :group_name
      t.integer   :user_id
      t.text   :user_code
      t.text   :user_name
      t.integer   :official_title_id
      t.text   :official_title_name
      t.text   :send_state
      t.datetime   :updated_at
      t.text   :updated_user
      t.text   :updated_group
      t.datetime   :created_at
      t.text   :created_user
      t.text   :created_group
      t.timestamps
    end
  end
end
