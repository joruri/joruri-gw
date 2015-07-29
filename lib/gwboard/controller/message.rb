# -*- encoding: utf-8 -*-
module Gwboard::Controller::Message

  def ret_image_message
    if @item.upload_graphic_file_size_capacity_unit == 'MB'
      used = @item.upload_graphic_file_size_currently.to_f / 1.megabyte.to_f
      capa_div = @item.upload_graphic_file_size_capacity.megabyte.to_f
    else
      used = @item.upload_graphic_file_size_currently.to_f / 1.gigabyte.to_f
      capa_div = @item.upload_graphic_file_size_capacity.gigabytes.to_f
    end
    availability = 0
    availability = (@item.upload_graphic_file_size_currently / capa_div) * 100 unless capa_div == 0
    tmp = availability * 100
    tmp = tmp.to_i
    availability = sprintf('%g',tmp.to_f / 100)
    tmp = used * 100
    tmp = tmp.to_i
    used = sprintf('%g',tmp.to_f / 100)
    used = used.to_s + @item.upload_graphic_file_size_capacity_unit
    return "現在約#{used}利用しています。利用率は約#{availability}%です。"
  end

  def ret_document_message
    if @item.upload_document_file_size_capacity_unit == 'MB'
      used = @item.upload_document_file_size_currently.to_f / 1.megabyte.to_f
      capa_div = @item.upload_document_file_size_capacity.megabyte.to_f
    else
      used = @item.upload_document_file_size_currently.to_f / 1.gigabyte.to_f
      capa_div = @item.upload_document_file_size_capacity.gigabytes.to_f
    end
    availability = 0
    availability = (@item.upload_document_file_size_currently / capa_div) * 100 unless capa_div == 0
    tmp = availability * 100
    tmp = tmp.to_i
    availability = sprintf('%g',tmp.to_f / 100)
    tmp = used * 100
    tmp = tmp.to_i
    used = sprintf('%g',tmp.to_f / 100)
    used = used.to_s + @item.upload_document_file_size_capacity_unit
    return "現在約#{used}利用しています。利用率は約#{availability}%です。"
  end
end