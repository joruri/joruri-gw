class CreateGwsubSb06BudgetRoles < ActiveRecord::Migration
  def change
    create_table :gwsub_sb06_budget_roles do |t|
      t.text   :code
      t.text   :name
      t.datetime   :created_at
      t.text   :created_user
      t.text   :created_group
      t.datetime   :updated_at
      t.text   :updated_user
      t.text   :updated_group
      t.timestamps
    end
  end
end
