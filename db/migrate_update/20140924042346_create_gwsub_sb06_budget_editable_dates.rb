class CreateGwsubSb06BudgetEditableDates < ActiveRecord::Migration
  def change
    create_table :gwsub_sb06_budget_editable_dates do |t|
      t.datetime   :start_at
      t.datetime   :end_at
      t.datetime   :recognize_at
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
