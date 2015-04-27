class AddWikiToGwbbsDocs < ActiveRecord::Migration
  def change
    add_column :gwbbs_docs, :wiki, :integer
    Gwbbs::Doc.update_all(:wiki => 0)
  end
end
