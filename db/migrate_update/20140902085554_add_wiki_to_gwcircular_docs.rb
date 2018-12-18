class AddWikiToGwcircularDocs < ActiveRecord::Migration
  def change
    add_column :gwcircular_docs, :wiki, :integer
    Gwcircular::Doc.update_all(:wiki => 0)
  end
end
