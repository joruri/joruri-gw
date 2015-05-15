class ChangeCreaterIdColumnTypeOnGwWorkflowDocs < ActiveRecord::Migration
  def change
    change_column :gw_workflow_docs, :creater_id, :integer
  end
end
