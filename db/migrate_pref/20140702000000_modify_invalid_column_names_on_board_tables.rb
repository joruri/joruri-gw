class ModifyInvalidColumnNamesOnBoardTables < ActiveRecord::Migration
  def change
    execute "alter table gwfaq_controls change column `  	upload_document_file_size_currently` `upload_document_file_size_currently` decimal(17,0);"
    execute "alter table gwqa_controls change column ` upload_document_file_size_currently` `upload_document_file_size_currently` decimal(17,0);"
    execute "alter table doclibrary_controls change column ` upload_document_file_size_currently` `upload_document_file_size_currently` decimal(17,0);"
    execute "alter table digitallibrary_controls change column ` upload_document_file_size_currently` `upload_document_file_size_currently` decimal(17,0);"
  end
end
