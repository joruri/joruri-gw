class CreateGwsubSb12Groups < ActiveRecord::Migration
  def change
    create_table :gwsub_sb12_groups do |t|
      t.text     :state
      t.string   :code
      t.text     :name
      t.integer  :sort_no
      t.integer  :ldap
      t.datetime :latest_updated_at
    end
  end
end
