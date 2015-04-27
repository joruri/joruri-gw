module Concerns::Gwbbs::Doc::Form004
  extend ActiveSupport::Concern

  included do
    with_options if: :form_name_form004? do |f|
      f.validates :inpfld_001, presence: { message: "職を入力してください。" }
      f.validates :title, presence: { message: "氏名を入力してください。" }
      f.validates :body, presence: { message: "電話番号を入力してください。" }
      f.validates :inpfld_002, presence: { message: "メールアドレスを入力してください。" }
    end
  end

  def form_name_form004?
    form_name == 'form004'
  end
end
