module Concerns::Gwbbs::Doc::Form007
  extend ActiveSupport::Concern

  included do
    with_options if: :form_name_form007? do |f|
      f.after_validation :set_inpfld_006_for_form007
      f.validates :title, presence: { message: "文書名を入力してください。" }
      f.validates :inpfld_002, presence: { message: "担当別を入力してください。" }
      f.validates :inpfld_006d, presence: { message: "国通知日を入力してください。" }
    end
  end

  def form_name_form007?
    form_name == 'form007'
  end

  private

  def set_inpfld_006_for_form007
    self.inpfld_006 = Gwboard.fyear_to_namejp_ymd(self.inpfld_006d)
    self.inpfld_006w = Gwboard.fyear_to_namejp_ym(self.inpfld_006d)
  end
end
