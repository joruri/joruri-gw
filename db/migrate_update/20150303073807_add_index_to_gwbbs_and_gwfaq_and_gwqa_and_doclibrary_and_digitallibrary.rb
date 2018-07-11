class AddIndexToGwbbsAndGwfaqAndGwqaAndDoclibraryAndDigitallibrary < ActiveRecord::Migration
  def change
    # gwbbs
    add_index :gwbbs_controls, :notification
    add_index :gwbbs_adms, :title_id
    add_index :gwbbs_categories, :title_id
    add_index :gwbbs_docs, :title_id
    add_index :gwbbs_roles, :title_id

    add_index :gwbbs_comments, :title_id
    add_index :gwbbs_comments, :parent_id
    add_index :gwbbs_files, :title_id
    add_index :gwbbs_files, :parent_id
    add_index :gwbbs_recognizers, :title_id
    add_index :gwbbs_recognizers, :parent_id

    # gwfaq
    add_index :gwfaq_controls, :notification
    add_index :gwfaq_adms, :title_id
    add_index :gwfaq_categories, :title_id
    add_index :gwfaq_roles, :title_id

    add_index :gwfaq_files, :title_id
    add_index :gwfaq_files, :parent_id
    add_index :gwfaq_recognizers, :title_id
    add_index :gwfaq_recognizers, :parent_id

    # gwqa
    add_index :gwqa_controls, :notification
    add_index :gwqa_adms, :title_id
    add_index :gwqa_categories, :title_id
    add_index :gwqa_docs, :title_id
    add_index :gwqa_roles, :title_id

    add_index :gwqa_files, :title_id
    add_index :gwqa_files, :parent_id
    add_index :gwqa_recognizers, :title_id
    add_index :gwqa_recognizers, :parent_id

    # doclibrary
    add_index :doclibrary_controls, :notification
    add_index :doclibrary_adms, :title_id
    add_index :doclibrary_categories, :title_id
    add_index :doclibrary_roles, :title_id

    add_index :doclibrary_files, :title_id
    add_index :doclibrary_files, :parent_id
    add_index :doclibrary_recognizers, :title_id
    add_index :doclibrary_recognizers, :parent_id

    # digitallibrary
    add_index :digitallibrary_controls, :notification
    add_index :digitallibrary_adms, :title_id
    add_index :digitallibrary_docs, :title_id
    add_index :digitallibrary_roles, :title_id

    add_index :digitallibrary_files, :title_id
    add_index :digitallibrary_files, :parent_id
    add_index :digitallibrary_recognizers, :title_id
    add_index :digitallibrary_recognizers, :parent_id
  end
end
