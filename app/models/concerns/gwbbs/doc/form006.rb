module Concerns::Gwbbs::Doc::Form006
  extend ActiveSupport::Concern

  included do
    with_options if: :form_name_form006? do |f|
      f.after_validation :set_inpfld_006_for_form006
      f.validates :title, presence: { message: "文書名を入力してください。" }
      f.validates :inpfld_002, presence: { message: "区分を入力してください。" }
      f.validates :inpfld_006d, presence: { message: "通知日を入力してください。" }
    end
    scope :index_order_with_params_form006, ->(control, params) {
      case params[:state]
      when "GROUP"
        order(inpfld_002: :asc, inpfld_006d: :desc, latest_updated_at: :desc)
      when "CATEGORY"
        docs = Gwbbs::Doc.arel_table
        cats = Gwbbs::Category.arel_table
        order(cats[:sort_no].asc, docs[:category1_id].asc, docs[:inpfld_006d].desc, docs[:latest_updated_at].desc).joins(:category)
      else
        order(inpfld_006d: :desc, latest_updated_at: :desc)
      end
    }
  end

  def form_name_form006?
    form_name == 'form006'
  end

  private

  def set_inpfld_006_for_form006
    self.inpfld_006 = Gwboard.fyear_to_namejp_ymd(self.inpfld_006d)
    self.inpfld_006w = Gwboard.fyear_to_namejp_ym(self.inpfld_006d)
  end
end
