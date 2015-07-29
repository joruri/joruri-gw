# -*- encoding: utf-8 -*-
class Gwsub::Sb04dividedutie < Gwsub::GwsubPref
  include System::Model::Base
  include Cms::Model::Base::Content

  def self.dividedutie_data_save(params, _item, mode, options={})
    par_item = params[:item].dup
    save_flg = true

    if !par_item[:divide_duties_order].blank? && par_item[:divide_duties_order] !~ /^[0-9]+$/
      _item.errors.add :divide_duties_order, "は、半角数字で入力してください。"
      save_flg = false
    end
    return save_flg
  end
end
