class MigrateStateDataOnGwWorkflowDocs < ActiveRecord::Migration
  def up
    Gwworkflow::Doc.without_preparation.find_each do |doc|
      doc.update_columns(state: doc._real_state)
    end
  end

  def down
  end
end
