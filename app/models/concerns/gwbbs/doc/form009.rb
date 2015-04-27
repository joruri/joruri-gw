module Concerns::Gwbbs::Doc::Form009
  extend ActiveSupport::Concern

  included do
    with_options if: :form_name_form009? do |f|
      f.validates :title, presence: { message: "タイトルを入力してください。" }, 
        length: { maximum: 140, message: "タイトルは140文字以内で記入してください。" }
    end
  end

  def form_name_form009?
    form_name == 'form009'
  end
end
