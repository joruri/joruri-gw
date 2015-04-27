module Concerns::Gwbbs::Doc::Form001
  extend ActiveSupport::Concern

  included do
    with_options if: :form_name_form001? do |f|
      f.validates :title, presence: { message: "タイトルを入力してください。" }, 
        length: { maximum: 140, message: "タイトルは140文字以内で記入してください。" }
    end
  end

  def form_name_form001?
    form_name == 'form001'
  end
end
