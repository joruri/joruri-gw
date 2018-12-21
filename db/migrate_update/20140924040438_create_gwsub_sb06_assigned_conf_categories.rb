class CreateGwsubSb06AssignedConfCategories < ActiveRecord::Migration
  def change
    create_table :gwsub_sb06_assigned_conf_categories do |t|
      t.integer   :cat_sort_no
      t.text   :cat_code
      t.text   :cat_name
      t.datetime   :created_at
      t.text   :created_user
      t.text   :created_group
      t.datetime   :updated_at
      t.text   :updated_user
      t.text   :updated_group
      t.text   :select_list
      t.timestamps
    end
  end
end
