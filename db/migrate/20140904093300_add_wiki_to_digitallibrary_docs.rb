class AddWikiToDigitallibraryDocs < ActiveRecord::Migration
  def change
    add_column :digitallibrary_docs, :wiki, :integer
    Digitallibrary::Doc.update_all(:wiki => 0)
  end
end
