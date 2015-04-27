module Concerns::Doclibrary::Doc::Form001
  extend ActiveSupport::Concern

  included do
    with_options unless: :state_preparation? do |f|
      f.with_options if: :form_name_form001? do |f2|
        f2.validates :title, presence: { message: "文書名を入力してください。" }
        f2.validates :section_code, presence: { message: "を設定してください。" }
        f2.validates :category1_id, presence: { message: "分類フォルダを設定してください。" }
      end
    end
    scope :index_order_with_params_form001, ->(control, params) {
      docs = Doclibrary::Doc.arel_table
      folders = Doclibrary::Folder.arel_table
      case params[:state]
      when "DATE", "DRAFT", "RECOGNIZE", "PUBLISH"
        order(docs[:latest_updated_at].desc, folders[:sort_no].asc, docs[:category1_id].asc, docs[:title].asc).joins(:folder)
      when "GROUP"
        order(docs[:section_code].asc, folders[:sort_no].asc, docs[:category1_id].asc, docs[:latest_updated_at].desc).joins(:folder)
      else
        order(folders[:sort_no].asc, docs[:section_code].asc, docs[:title].asc, docs[:latest_updated_at].desc).joins(:folder)
      end
    }
  end

  def form_name_form001?
    form_name == 'form001'
  end
end
