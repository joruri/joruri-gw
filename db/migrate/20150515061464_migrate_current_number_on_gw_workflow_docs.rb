class MigrateCurrentNumberOnGwWorkflowDocs < ActiveRecord::Migration
  def up
    Gwworkflow::Doc.without_preparation.find_each do |doc|
      doc.send(:update_current_number)
    end
  end
  def down
  end
end
