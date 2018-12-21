class CreateGwsubSb06AssignedConfItems < ActiveRecord::Migration
  def change
    create_table :gwsub_sb06_assigned_conf_items do |t|
      t.integer   :fyear_id
      t.text   :fyear_markjp
      t.integer   :conf_kind_id
      t.integer   :item_sort_no
      t.text   :item_title
      t.integer   :item_max_count
      t.datetime   :created_at
      t.text   :created_user
      t.text   :created_group
      t.datetime   :updated_at
      t.text   :updated_user
      t.text   :updated_group
      t.integer   :select_list
      t.timestamps
    end
  end
end
