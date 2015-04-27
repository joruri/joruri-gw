module Gwboard::Model::Control::Base

  def sidelist_style
    str = ''
    styles = []
    styles << %Q[background-image:url(#{self.wallpaper});] if self.wallpaper.present?
    styles << %Q[background-color:#{self.left_index_bg_color};] if self.left_index_bg_color.present?
    str = %Q[style="#{styles.join()}"] if styles.size != 0
    return str
  end

  def states
    {'public' => '公開', 'closed' => '非公開'}
  end

  def importance_states
    {'0' => '使用しない', '1' => '使用する'}
  end

  def category_states
    {'0' => '使用しない', '1' => '使用する'}
  end

  def one_line_use_states
    {'0' => '使用しない', '1' => '使用する'}
  end

  def notification_states
    {'0' => '使用しない', '1' => '使用する'}
  end

  def recognize_states
    {'0' => '不要', '1' => '必須', '2' => '任意'}
  end

  def state_list
    [["公開","public"], ["非公開","closed"]]
  end

  def recognize_states_list
    [["不要","0"],["必須","1"],["任意","2"]]
  end

  def use_daily_states_list
    [["使用する","0"],["使用しない","1"]]
  end

  def use_states_list
    [["使用しない","0"],["使用する","1"]]
  end

  def display_states_list
    [["表示する",0], ["表示しない",1]]
  end

  def default_limit_line
    [
      ['10行', 10],
      ['20行', 20],
      ['30行', 30],
      ['50行', 50],
      ['100行',100]
    ]
  end

  def list_view_name
    [['表示する', true],['表示しない', false]]
  end

  def restrict_access_use
    [['使用しない', false],['使用する', true]]
  end

  def function_forbidden
    [['許可する', false],['不可', true]]
  end

  def index_view_name
    [['表示する', '1'],['表示しない', '0']]
  end

  def size_unit_name
    [['MB', 'MB'],['GB', 'GB']]
  end

  def default_folder_mode
    [['分類表示', 'CATEGORY'],['所属表示', 'GROUP']]
  end

  def default_mode_name
    [['日付表示', ''],['分類表示', 'CATEGORY'],['所属表示', 'GROUP']]
  end

  def left_index_pattern_name
    [['全内容を表示', 0],['選択された内容のみ', 1]]
  end

  def delete_date_name
    [['しない', 'none'],['する', 'use']]
  end

  def use_section_admin
    [['使用しない', ''],['使用する', 'section_code']]
  end

  def preview_mode_name
    [['プレビュー状態で設定（新規作成では、公開画面を標準色で設定します。）', true],['設定したデザインを公開', false]]
  end

  def category1_control_title
    category1_name.blank? ? '分類' : category1_name.to_s
  end

  def use_recognize?
    recognize.to_s != '0'
  end

  def use_free_public?
    recognize.to_s != '1'
  end

  def use_other_system?
    other_system_link.present?
  end

  def use_old_upload_system?
    !upload_system.in?(1..4)
  end

  concerning :UploadGraphicFileSize do
    def upload_graphic_file_size_capacity_label
      "#{upload_graphic_file_size_capacity}#{upload_graphic_file_size_capacity_unit}"
    end

    def upload_graphic_file_size_capacity_in_bytes
      if upload_graphic_file_size_capacity_unit == 'MB'
        upload_graphic_file_size_capacity.to_i.megabytes.to_f
      else
        upload_graphic_file_size_capacity.to_i.gigabytes.to_f
      end
    end

    def upload_graphic_file_size_currently_in_units
      if upload_graphic_file_size_capacity_unit == 'MB'
        upload_graphic_file_size_currently.to_f / 1.megabyte.to_f
      else
        upload_graphic_file_size_currently.to_f / 1.gigabyte.to_f
      end
    end

    def upload_graphic_file_size_currently_label
      "#{sprintf("%.2f", upload_graphic_file_size_currently_in_units)}#{upload_graphic_file_size_capacity_unit}"
    end

    def upload_graphic_file_size_currently_percent
      if upload_graphic_file_size_capacity_in_bytes != 0
        (upload_graphic_file_size_currently / upload_graphic_file_size_capacity_in_bytes) * 100
      else
        0
      end
    end

    def upload_graphic_file_size_currently_percent_label
      "#{sprintf("%.2f", upload_graphic_file_size_currently_percent)}%"
    end

    def upload_graphic_file_size_full?
      upload_graphic_file_size_capacity_in_bytes < upload_graphic_file_size_currently
    end

    def upload_graphic_file_size_currently_message
      "現在約#{upload_graphic_file_size_currently_label}利用しています。" \
      "利用率は約#{upload_graphic_file_size_currently_percent_label}です。"
    end

    def upload_graphic_file_size_max_message
      "画像ファイルは、１ファイル#{upload_graphic_file_size_max}MBまで登録可能です。"
    end

    def upload_graphic_file_size_capacity_message
      "画像ファイルの利用可能容量は#{upload_graphic_file_size_capacity_label}です。" \
      "現在約#{upload_graphic_file_size_currently_label}利用しています。" \
      "利用率は約#{upload_graphic_file_size_currently_percent_label}です。"
    end
  end

  concerning :UploadDocumentFileSize do
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

  def upload_file_size_full?
    upload_graphic_file_size_full? || upload_document_file_size_full?
  end
end
