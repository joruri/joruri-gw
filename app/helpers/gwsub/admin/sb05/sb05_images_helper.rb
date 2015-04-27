module Gwsub::Admin::Sb05::Sb05ImagesHelper

  #掲示板関連の登録で、画像のアップロードと貼り付けを行う
  def gwsub_attach_form(form, item)
    form_id = '' if form_id.blank?
    render 'gwsub/admin/tool/attaches/form', f: form, item: item
  end
end
