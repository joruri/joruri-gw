module Concerns::Gwbbs::Doc::Form005
  extend ActiveSupport::Concern

  included do
    with_options if: :form_name_form005? do |f|
      f.validates :title, presence: { message: "事務の名称を入力してください。" }
      f.validates :body, presence: { message: "保有課名を入力してください。" }
    end
  end

  def form_name_form005?
    form_name == 'form005'
  end
end
