class CreateGwsubSb06BudgetAssigns < ActiveRecord::Migration
  def change
    create_table :gwsub_sb06_budget_assigns do |t|
      t.integer   :group_parent_id
      t.text   :group_parent_ou
      t.text   :group_parent_code
      t.text   :group_parent_name
      t.integer   :group_id
      t.text   :group_ou
      t.text   :group_code
      t.text   :group_name
      t.integer   :multi_group_parent_id
      t.text   :multi_group_parent_ou
      t.text   :multi_group_parent_code
      t.text   :multi_group_parent_name
      t.integer   :multi_group_id
      t.text   :multi_group_ou
      t.text   :multi_group_code
      t.text   :multi_group_name
      t.text   :multi_sequence
      t.text   :multi_user_code
      t.integer   :user_id
      t.text   :user_code
      t.text   :user_name
      t.integer   :budget_role_id
      t.text   :budget_role_code
      t.text   :budget_role_name
      t.text   :admin_state
      t.text   :main_state
      t.datetime   :updated_at
      t.text   :updated_user
      t.text   :updated_group
      t.datetime   :created_at
      t.text   :created_user
      t.text   :created_group
      t.timestamps
    end
  end
end
