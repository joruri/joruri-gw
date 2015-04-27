class AddIndexToGwboardImagesAndGwboardDbFiles < ActiveRecord::Migration
  def change
    # gwbbs
    add_index :gwbbs_images, :title_id
    add_index :gwbbs_images, :parent_id
    add_index :gwbbs_db_files, :title_id
    add_index :gwbbs_db_files, :parent_id
    # gwfaq
    add_index :gwfaq_images, :title_id
    add_index :gwfaq_images, :parent_id
    add_index :gwfaq_db_files, :title_id
    add_index :gwfaq_db_files, :parent_id
    # gwqa
    add_index :gwqa_images, :title_id
    add_index :gwqa_images, :parent_id
    add_index :gwqa_db_files, :title_id
    add_index :gwqa_db_files, :parent_id
    # doclibrary
    add_index :doclibrary_images, :title_id
    add_index :doclibrary_images, :parent_id
    add_index :doclibrary_db_files, :title_id
    add_index :doclibrary_db_files, :parent_id
    # digitallibrary
    add_index :digitallibrary_images, :title_id
    add_index :digitallibrary_images, :parent_id
    add_index :digitallibrary_db_files, :title_id
    add_index :digitallibrary_db_files, :parent_id
  end
end
