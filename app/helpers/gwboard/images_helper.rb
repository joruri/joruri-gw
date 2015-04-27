module Gwboard::ImagesHelper

  def gwboard_image_form(form, item, form_id)
    form_id = '' if form_id.blank?
    render 'gwboard/admin/tool/images/form', f: form, item: item, form_id: form_id
  end

  def gwboard_attach_form(form, item)
    form_id = '' if form_id.blank?
    render 'gwboard/admin/tool/attaches/form', f: form, item: item
  end

  def gwboard_attachments_form(form, item)
    form_id = '' if form_id.blank?
    render 'gwboard/admin/tool/attachments/form', f: form, item: item
  end

  def gwboard_map_form(form, item, field_id, map_label)
    field_id = '' if field_id.blank?
    map_label = '' if map_label.blank?
    render 'gwboard/admin/tool/maps/form', f: form, item: item, field_id: field_id, map_label: map_label
  end
end
