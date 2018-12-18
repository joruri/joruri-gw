class CreateGwsubSb05Notices < ActiveRecord::Migration
  def change
    create_table :gwsub_sb05_notices do |t|
      t.integer :media_id
      t.integer :media_code
      t.text    :media_name
      t.integer :categories_code
      t.text    :categories_name
      t.text    :sample
      t.text    :remarks
      t.text    :form_templates
      t.text    :admin_remarks
      t.datetime   :updated_at
      t.text    :updated_user
      t.text    :updated_group
      t.datetime   :created_at
      t.text    :created_user
      t.text    :created_group
      t.timestamps
    end
  end
end
