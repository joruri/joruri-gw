class CreateGwsubSb05Users < ActiveRecord::Migration
  def change
    create_table :gwsub_sb05_users do |t|
      t.integer :user_id
      t.integer :org_id
      t.text   :user_code
      t.text   :user_name
      t.text   :user_display
      t.text   :org_code
      t.text   :org_name
      t.text   :org_display
      t.text   :telephone
      t.text   :notes_imported
      t.datetime   :notes_updated_at
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
