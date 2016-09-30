module Gw::UploadsHelper

  def gw_attachments_form(form, item, system_name)
    form_id = '' if form_id.blank?
    render 'gw/admin/files/attachments/form', f: form, item: item, system_name: system_name
  end

end
