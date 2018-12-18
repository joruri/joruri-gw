class CreateGwsubSb06AssignedConfGroups < ActiveRecord::Migration
  def change
    create_table :gwsub_sb06_assigned_conf_groups do |t|
      t.integer   :fyear_id
      t.text   :fyear_markjp
      t.integer   :group_id
      t.text   :group_code
      t.text   :group_name
      t.datetime   :updated_at
      t.text   :updated_user
      t.text   :updated_group
      t.datetime   :created_at
      t.text   :created_user
      t.text   :created_group
      t.integer   :categories_id
      t.integer   :cat_sort_no
      t.text   :cat_code
      t.text   :cat_name
      t.timestamps
    end
  end
end
