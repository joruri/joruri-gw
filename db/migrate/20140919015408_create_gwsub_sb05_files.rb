class CreateGwsubSb05Files < ActiveRecord::Migration
  def change
    create_table :gwsub_sb05_files do |t|
      t.integer :unid
      t.integer :content_id
      t.text    :state
      t.datetime   :created_at
      t.datetime   :updated_at
      t.datetime   :recognized_at
      t.datetime   :published_at
      t.datetime   :latest_updated_at
      t.integer :parent_id
      t.integer :title_id
      t.string   :content_type, :limit=>255
      t.text    :filename
      t.text    :memo
      t.integer :size
      t.integer :width
      t.integer :height
      t.integer :db_file_id
      t.text    :file_state
      t.timestamps
    end
  end
end
