class CreateGwsubSb06BudgetNotices < ActiveRecord::Migration
  def change
    create_table :gwsub_sb06_budget_notices do |t|
      t.text   :kind
      t.text   :title
      t.text   :bbs_url
      t.text   :remarks
      t.text   :state
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
