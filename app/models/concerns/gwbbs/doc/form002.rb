module Concerns::Gwbbs::Doc::Form002
  extend ActiveSupport::Concern

  included do
    with_options if: :form_name_form002? do |f|
      f.validates :title, presence: { message: "研修名を入力してください。" }
      f.validate :validate_form002
    end
  end

  def form_name_form002?
    form_name == 'form002'
  end

  private

  def validate_form002
    if self.inpfld_001 != "" && self.inpfld_002 != ""
      if (self.inpfld_001.to_time rescue nil) == nil
        return errors.add :inpfld_001,"研修開始日入力に誤りがあります。"
      end
      if (self.inpfld_002.to_time rescue nil) == nil
        return errors.add :inpfld_002,"申込締切日入力に誤りがあります。"
      end
      if self.inpfld_001.to_time < self.inpfld_002.to_time
        errors.add :inpfld_002,"申込締切日は、研修開始日より前の日付に設定してください。"
      end
    end
  end
end
