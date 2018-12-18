class CreateGwbbsItemimages < ActiveRecord::Migration
  def change
    create_table :gwbbs_itemimages do |t|
      t.string   :type_name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :title_id
      t.text     :filename
      t.integer  :width
      t.integer  :height
    end
  end
end
