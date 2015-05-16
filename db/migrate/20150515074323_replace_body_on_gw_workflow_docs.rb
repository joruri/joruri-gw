class ReplaceBodyOnGwWorkflowDocs < ActiveRecord::Migration
  def up
    execute 'update gw_workflow_docs set body = replace(body, "\\r\\n", "<p></p>")'
  end
  def down
  end
end
