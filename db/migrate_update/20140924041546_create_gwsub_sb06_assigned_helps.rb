class CreateGwsubSb06AssignedHelps < ActiveRecord::Migration
  def change
    create_table :gwsub_sb06_assigned_helps do |t|
      t.integer   :help_kind
      t.integer   :conf_cat_id
      t.integer   :conf_kind_sort_no
      t.integer   :conf_kind_id
      t.integer   :fyear_id
      t.text   :fyear_markjp
      t.integer   :conf_group_id
      t.text   :title
      t.text   :bbs_url
      t.text   :remarks
      t.datetime   :created_at
      t.text   :created_user
      t.text   :created_group
      t.datetime   :updated_at
      t.text   :updated_user
      t.text   :updated_group
      t.string   :state, :limit => 255
      t.integer   :sort_no
      t.timestamps
    end
  end
end
