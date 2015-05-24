class MigrateStateDataOnGwWorkflowDocs < ActiveRecord::Migration
  def up
    Gwworkflow::Doc.without_preparation.find_each do |doc|
      doc.send(:update_state)
    end
  end
  def down
  end
end
