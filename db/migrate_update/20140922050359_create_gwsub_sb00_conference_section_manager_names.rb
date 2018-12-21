class CreateGwsubSb00ConferenceSectionManagerNames < ActiveRecord::Migration
  def change
    create_table :gwsub_sb00_conference_section_manager_names do |t|
      t.integer   :fyear_id
      t.text :markjp
      t.string :state, :limit => 255
      t.integer   :parent_gid
      t.integer   :gid
      t.integer   :g_sort_no
      t.string :g_code, :limit => 255
      t.text :g_name
      t.text :manager_name
      t.datetime   :deleted_at
      t.datetime   :updated_at
      t.datetime   :created_at
      t.timestamps
    end
  end
end
