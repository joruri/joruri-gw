# -*- encoding: utf-8 -*-

module Gwboard::Model::ControlCommon
  include Gwboard::Model::AttachFile

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
    return [
      ['10行', 10],
      ['20行', 20],
      ['30行', 30],
      ['50行', 50],
      ['100行',100]
    ]
  end

  def list_view_name
    return [
      ['表示する', true],
      ['表示しない', false]
    ]
  end

  def restrict_access_use
    return [
      ['使用しない', false],
      ['使用する', true]
    ]
  end

  def function_forbidden
    return [
      ['許可する', false],
      ['不可', true]
    ]
  end


  def index_view_name
    return [
      ['表示する', '1'],
      ['表示しない', '0']
    ]
  end

  def size_unit_name
    return [
      ['MB', 'MB'],
      ['GB', 'GB']
    ]
  end

  def default_folder_mode
    return [
      ['分類表示', 'CATEGORY'],
      ['所属表示', 'GROUP']
    ]
  end

  def default_mode_name
    return [
      ['日付表示', ''],
      ['分類表示', 'CATEGORY'],
      ['所属表示', 'GROUP']
    ]
  end

  def left_index_pattern_name
    return [
      ['全内容を表示', 0],
      ['選択された内容のみ', 1]
    ]
  end

  def delete_date_name
    return [
      ['しない', 'none'],
      ['する', 'use']]
  end

  def use_section_admin
    return [
      ['使用しない', ''],
      ['使用する', 'section_code']
      ]
  end

  def preview_mode_name
    return [
      ['プレビュー状態で設定（新規作成では、公開画面を標準色で設定します。）', true],
      ['設定したデザインを公開', false]
    ]
  end

  def category1_control_title
    self.category1_name.blank? ? '分類' : self.category1_name.to_s
  end

  def use_recognize
    ret = true
    ret = false if self.recognize.to_s == '0'
    return ret
  end

  def use_free_public
    ret = true
    ret = false if self.recognize.to_s == '1'
    return ret
  end

  def use_other_system
    ret = false
    ret = true unless self.other_system_link.blank?
    return ret
  end

  def item_path
    return "#{Core.current_node.public_uri}"
  end

  def new_doc_path
    if self.system_name == 'gwqa'
      return "#{Core.current_node.public_uri}new?title_id=#{self.id}&p_id=Q"
    end
    return "#{Core.current_node.public_uri}new?title_id=#{self.id}"
  end

  def new_portal_doc_path
    ret = "/_admin/#{self.system_name}/docs/new?title_id=#{self.id}"
    ret = "#{ret}&p_id=Q" if self.system_name == 'gwqa'
    return ret
  end

  def show_path
    return "#{Core.current_node.public_uri}#{self.id}/"
  end

  def edit_path
    return "#{Core.current_node.public_uri}#{self.id}/edit"
  end

  def delete_path
    return "#{Core.current_node.public_uri}#{self.id}/delete"
  end

  def update_path
    return "#{Core.current_node.public_uri}#{self.id}/update"
  end

end
