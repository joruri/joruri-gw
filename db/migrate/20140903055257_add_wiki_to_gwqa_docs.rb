class AddWikiToGwqaDocs < ActiveRecord::Migration
  def change
    add_column :gwqa_docs, :wiki, :integer
    Gwqa::Doc.update_all(:wiki => 0)
  end
end
