class AddWikiToGwfaqDocs < ActiveRecord::Migration
  def change
    add_column :gwfaq_docs, :wiki, :integer
    Gwfaq::Doc.update_all(:wiki => 0)
  end
end
