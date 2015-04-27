module Gwworkflow::DocsHelper

  def gwworkflow_attachments_form(form, item)
    form_id = '' if form_id.blank?
    render 'attachment', f: form, item: item
  end
end
