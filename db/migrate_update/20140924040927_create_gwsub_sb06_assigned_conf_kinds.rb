class CreateGwsubSb06AssignedConfKinds < ActiveRecord::Migration
  def change
    create_table :gwsub_sb06_assigned_conf_kinds do |t|
      t.integer   :fyear_id
      t.text   :fyear_markjp
      t.integer   :conf_cat_id
      t.text   :conf_kind_code
      t.text   :conf_kind_name
      t.integer   :conf_kind_sort_no
      t.text   :conf_menu_name
      t.text   :conf_to_name
      t.text   :conf_title
      t.text   :conf_form_no
      t.integer   :conf_max_count
      t.datetime   :updated_at
      t.text   :updated_user
      t.text   :updated_group
      t.datetime   :created_at
      t.text   :created_user
      t.text   :created_group
      t.integer   :select_list
      t.text   :conf_body
      t.timestamps
    end
  end
end
