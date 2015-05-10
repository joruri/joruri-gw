module Gwboard::Model::Control::DocumentFileSize
  extend ActiveSupport::Concern

  def upload_document_file_size_capacity_label
    "#{upload_document_file_size_capacity}#{upload_graphic_file_size_capacity_unit}"
  end

  def upload_document_file_size_capacity_in_bytes
    if upload_document_file_size_capacity_unit == 'MB'
      upload_document_file_size_capacity.to_i.megabytes.to_f
    else
      upload_document_file_size_capacity.to_i.gigabytes.to_f
    end
  end

  def upload_document_file_size_currently_in_units
    if upload_document_file_size_capacity_unit == 'MB'
      upload_document_file_size_currently.to_f / 1.megabyte.to_f
    else
      upload_document_file_size_currently.to_f / 1.gigabyte.to_f
    end
  end

  def upload_document_file_size_currently_label
    "#{sprintf("%.2f", upload_document_file_size_currently_in_units)}#{upload_document_file_size_capacity_unit}"
  end

  def upload_document_file_size_currently_percent
    if upload_document_file_size_capacity_in_bytes != 0
      (upload_document_file_size_currently / upload_document_file_size_capacity_in_bytes) * 100
    else
      0
    end
  end

  def upload_document_file_size_currently_percent_label
    "#{sprintf("%.2f", upload_document_file_size_currently_percent)}%"
  end

  def upload_document_file_size_full?
    upload_document_file_size_capacity_in_bytes < upload_document_file_size_currently
  end

  def upload_document_file_size_currently_message
    "現在約#{upload_document_file_size_currently_label}利用しています。" \
    "利用率は約#{upload_document_file_size_currently_percent_label}です。"
  end

  def upload_document_file_size_max_message
    "添付ファイルは、１ファイル#{upload_document_file_size_max}MBまで登録可能です。"
  end

  def upload_document_file_size_capacity_message
    "添付ファイルの利用可能容量は#{upload_document_file_size_capacity_label}です。" \
    "現在約#{upload_document_file_size_currently_label}利用しています。" \
    "利用率は約#{upload_document_file_size_currently_percent_label}です。"
  end
end
