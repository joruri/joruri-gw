module Gwboard::Model::Control::Base
  extend ActiveSupport::Concern
  include Gwboard::Model::Control::GraphicFileSize
  include Gwboard::Model::Control::DocumentFileSize

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

  def upload_file_size_full?
    upload_graphic_file_size_full? || upload_document_file_size_full?
  end
end
