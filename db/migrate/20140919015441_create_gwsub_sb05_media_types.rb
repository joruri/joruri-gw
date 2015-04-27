class CreateGwsubSb05MediaTypes < ActiveRecord::Migration
  def change
    create_table :gwsub_sb05_media_types do |t|
      t.integer :media_code
      t.text    :media_name
      t.integer :categories_code
      t.text    :categories_name
      t.integer :max_size
      t.integer :state
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
