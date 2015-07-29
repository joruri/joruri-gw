#encoding:utf-8
module Gwworkflow::DocsHelper

  def gwworkflow_attachments_form(form, item)
    form_id = '' if form_id.blank?
    return render(:partial => 'attachment', :locals => {:f => form, :item => item})
  end

end
