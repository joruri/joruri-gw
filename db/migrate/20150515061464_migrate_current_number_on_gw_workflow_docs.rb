class MigrateCurrentNumberOnGwWorkflowDocs < ActiveRecord::Migration
  def change
    Gwworkflow::Doc.without_preparation.find_each do |doc|
      doc.update_columns(current_number: doc.current_step.number) if doc.current_step
    end
  end
end
