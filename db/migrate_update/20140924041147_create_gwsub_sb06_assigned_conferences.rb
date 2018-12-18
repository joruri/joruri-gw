class CreateGwsubSb06AssignedConferences < ActiveRecord::Migration
  def change
    create_table :gwsub_sb06_assigned_conferences do |t|
      t.datetime   :created_at
      t.text   :created_user
      t.integer   :created_user_id
      t.text   :created_group
      t.datetime   :updated_at
      t.text   :updated_user
      t.integer   :updated_user_id
      t.text   :updated_group
      t.text   :state
      t.integer   :categories_id
      t.integer   :cat_sort_no
      t.text   :cat_code
      t.text   :cat_name
      t.integer   :conf_kind_id
      t.integer   :conf_kind_sort_no
      t.text   :conf_kind_name
      t.integer   :fyear_id
      t.text   :fyear_markjp
      t.text   :fyear_namejp
      t.text   :conf_mark
      t.text   :conf_no
      t.integer   :conf_group_id
      t.text   :conf_group_code
      t.text   :conf_group_name
      t.datetime   :conf_at
      t.integer   :section_manager_id
      t.integer   :group_id
      t.text   :group_code
      t.text   :group_name
      t.text   :group_name_display
      t.text   :conf_kind_place
      t.integer   :conf_item_id
      t.integer   :conf_item_sort_no
      t.text   :conf_item_title
      t.text   :work_name
      t.text   :work_kind
      t.integer   :official_title_id
      t.text   :official_title_name
      t.integer   :sort_no
      t.integer   :user_id
      t.text   :user_name
      t.text   :extension
      t.text   :user_mail
      t.text   :user_job_name
      t.datetime   :start_at
      t.text   :remarks
      t.integer   :user_section_id
      t.text   :user_section_name
      t.integer   :user_section_sort_no
      t.integer   :main_group_id
      t.text   :main_group_name
      t.integer   :main_group_sort_no
      t.integer   :admin_group_id
      t.text   :admin_group_code
      t.text   :admin_group_name
      t.timestamps
    end
  end
end
