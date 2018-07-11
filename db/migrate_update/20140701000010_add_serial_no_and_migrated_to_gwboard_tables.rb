class AddSerialNoAndMigratedToGwboardTables < ActiveRecord::Migration
  def change
    # gwbbs
    [:gwbbs_categories, 
     :gwbbs_comments, 
     :gwbbs_db_files, 
     :gwbbs_docs, 
     :gwbbs_files, 
     :gwbbs_images, 
     :gwbbs_recognizers
    ].each do |table|
      add_column table, :serial_no, :integer
      add_column table, :migrated, :integer
    end

    # gwfaq
    [:gwfaq_categories, 
     :gwfaq_db_files, 
     :gwfaq_docs, 
     :gwfaq_files, 
     :gwfaq_images, 
     :gwfaq_recognizers
    ].each do |table|
      add_column table, :serial_no, :integer
      add_column table, :migrated, :integer
    end

    # gwqa
    [:gwqa_categories, 
     :gwqa_db_files, 
     :gwqa_docs, 
     :gwqa_files, 
     :gwqa_images, 
     :gwqa_recognizers
    ].each do |table|
      add_column table, :serial_no, :integer
      add_column table, :migrated, :integer
    end

    # doclibrary
    [:doclibrary_categories, 
     :doclibrary_db_files, 
     :doclibrary_docs, 
     :doclibrary_files, 
     :doclibrary_folder_acls,
     :doclibrary_folders,
     :doclibrary_group_folders,
     :doclibrary_images, 
     :doclibrary_recognizers
    ].each do |table|
      add_column table, :serial_no, :integer
      add_column table, :migrated, :integer
    end

    # digitallibrary
    [:digitallibrary_db_files, 
     :digitallibrary_docs, 
     :digitallibrary_files, 
     :digitallibrary_images, 
     :digitallibrary_recognizers
    ].each do |table|
      add_column table, :serial_no, :integer
      add_column table, :migrated, :integer
    end
  end
end
