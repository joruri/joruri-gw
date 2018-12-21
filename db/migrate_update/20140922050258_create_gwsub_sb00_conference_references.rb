class CreateGwsubSb00ConferenceReferences < ActiveRecord::Migration
  def change
    create_table :gwsub_sb00_conference_references do |t|
      t.integer   :fyear_id
      t.text :fyear_markjp
      t.text :kind_code
      t.text :title
      t.datetime   :updated_at
      t.text :updated_user
      t.text :updated_group
      t.datetime   :created_at
      t.text :created_user
      t.text :created_group
      t.text :kind_name
      t.integer   :group_id
      t.timestamps
    end
  end
end
