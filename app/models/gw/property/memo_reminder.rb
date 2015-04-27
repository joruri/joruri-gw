class Gw::Property::MemoReminder < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 1, name: "memo", type_name: "json" }
  end

  def default_options
    { memos: { unread_memos_display: '3', read_memos_display: '0' } }
  end

  def memos
    options_value['memos'] || {}
  end

  def unread_memos_display
    memos['unread_memos_display']
  end

  def read_memos_display
    memos['read_memos_display']
  end

  def display_options
    [['表示しない','0'],['当日のみ表示する','1'],['２日間表示する','2'],['３日間表示する','3'],['４日間表示する','4'],['５日間表示する','5']]
  end
end
