module Gwsub::Admin::Sb05::Sb05AttachesHelper

  #掲示板関連の登録で、画像のアップロードと貼り付けを行う
  def gwsub_attach_form_sb05(form, item)
    form_id = '' if form_id.blank?
    render 'gwsub/admin/tool/attaches/sb05_form', f: form, item: item
  end
end
