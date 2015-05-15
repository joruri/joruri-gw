class AddCurrentNumberToGwWorkflowDocs < ActiveRecord::Migration
  def change
    add_column :gw_workflow_docs, :current_number, :integer, default: 0
  end
end
