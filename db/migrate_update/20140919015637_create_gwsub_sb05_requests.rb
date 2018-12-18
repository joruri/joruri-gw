class CreateGwsubSb05Requests < ActiveRecord::Migration
  def change
    create_table :gwsub_sb05_requests do |t|
      t.integer :sb05_users_id
      t.text   :user_code
      t.text   :user_name
      t.text   :user_display
      t.text   :org_code
      t.text   :org_name
      t.text   :org_display
      t.text   :telephone
      t.integer :media_id
      t.integer :media_code
      t.text   :media_name
      t.integer :categories_code
      t.text   :categories_name
      t.datetime   :start_at
      t.datetime   :end_at
      t.text   :title
      t.text   :body1
      t.text   :magazine_url
      t.text   :magazine_url_mobile
      t.integer :mm_attachiment
      t.text   :img
      t.datetime   :contract_at
      t.datetime   :base_at
      t.text   :magazine_state
      t.text   :r_state
      t.text   :m_state
      t.text   :admin_remarks
      t.text   :notes_imported
      t.datetime   :notes_updated_at
      t.datetime   :updated_at
      t.text   :updated_user
      t.text   :updated_group
      t.datetime   :created_at
      t.text   :created_user
      t.text   :created_group
      t.text   :mm_image_state
      t.text   :attaches_file
      t.timestamps
    end
  end
end
