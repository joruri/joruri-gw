class CreateGwbbsFlags < ActiveRecord::Migration
  def change
    create_table :gwbbs_flags do |t|
      t.integer  :title_id
      t.integer  :parent_id
      t.string   :state
      t.string   :user_id
      t.string   :created_user
      t.string   :created_group
      t.string   :updated_user
      t.string   :updated_group
      t.timestamps null: false
    end
  end
end
