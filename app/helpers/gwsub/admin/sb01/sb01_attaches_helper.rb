module Gwsub::Admin::Sb01::Sb01AttachesHelper

  #画像のアップロードと貼り付けを行う
  def gwsub_attaches_form(form, item)
    form_id = '' if form_id.blank?
    return render(:partial => 'gwsub/admin/tool/attaches/form', :locals => {:f => form, :item => item})
  end
  #画像のアップロードと貼り付けを行う 　ソフトウェア追加届用
  def gwsub_attaches_sb01_training_form(form, item)
    form_id = '' if form_id.blank?
    return render(:partial => 'gwsub/admin/tool/attaches/sb01_training_form', :locals => {:f => form, :item => item})
  end
end
