class CreateGwsubSb06AssignedOfficialTitles < ActiveRecord::Migration
  def change
    create_table :gwsub_sb06_assigned_official_titles do |t|
      t.text   :official_title_code
      t.text   :official_title_name
     t.integer   :official_title_sort_no
      t.datetime   :created_at
      t.text   :created_user
      t.text   :created_group
      t.datetime   :updated_at
      t.text   :updated_user
      t.text   :updated_group
      t.timestamps
    end
  end
end
