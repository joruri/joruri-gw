class AddWikiToDoclibraryDocs < ActiveRecord::Migration
  def change
    add_column :doclibrary_docs, :wiki, :integer
    Doclibrary::Doc.update_all(:wiki => 0)
  end
end
