module Concerns::Doclibrary::Doc::Form002
  extend ActiveSupport::Concern

  included do
    with_options unless: :state_preparation? do |f|
      f.with_options if: :form_name_form002? do |f2|
        f2.before_validation :set_inpfld_for_form002
        f2.before_validation :set_note_for_form002
        f2.validates :title, presence: { message: "件名を入力してください。" }
        f2.validates :category1_id, presence: { message: "号区分,区分を設定してください。" }
        f2.validates :inpfld_001, presence: { message: "文書を選択してください。" }
        f2.validates :note, presence: { message: "文書に添付ファイルがありません。文書の内容を確認してください。" }
      end
    end
    scope :index_order_with_params_form002, ->(control, params) {
      order(inpfld_001: :asc, inpfld_002: :desc, inpfld_003: :desc, inpfld_004: :desc, inpfld_005: :asc, inpfld_006: :asc)
    }
  end

  def form_name_form002?
    form_name == 'form002'
  end

  def category_options_form002
    categories = []
    item = control.categories.where(state: 'public').order(id: :desc).all.each do |dep|
      if dep.sono2.blank?
        str_sono = dep.sono.to_s
      else
        str_sono = "#{dep.sono.to_s} - #{dep.sono2.to_s}"
      end
      categories << ["#{dep.wareki}#{dep.nen}年#{dep.gatsu}月その#{str_sono} : #{dep.filename}", dep.id]
    end
    categories
  end

  private

  def set_inpfld_for_form002
    return unless self.category

    self.inpfld_001 = self.category.wareki
    self.inpfld_002 = self.category.nen
    self.inpfld_003 = self.category.gatsu
    self.inpfld_004 = self.category.sono
    self.inpfld_005 = self.category.sono2
    self.inpfld_007 = self.category.sono2.present? ? "#{self.inpfld_004.to_s} - #{self.category.sono2}" : self.category.sono
  end

  def set_note_for_form002
    return unless file = category_files.first

    if 1 <= control.upload_system && control.upload_system <= 4
      self.note = file.file_uri(file.system_name)
    else
      self.note = "/_admin/gwboard/receipts/#{file.id}/download_object?system=#{file.system_name}&title_id=#{file.title_id}"
    end
  end
end
