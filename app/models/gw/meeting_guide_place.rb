class Gw::MeetingGuidePlace < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :meeting, :foreign_key => :prop_id, :class_name => 'Gw::PropMeetingroom'

  before_create :set_creator
  before_update :set_updator

  validates :sort_no, :state, :place, presence: true
  validates :place, length: { maximum: 20 }

  default_scope -> { where.not(state: 'deleted') }

  def state_label
    self.class.state_show(state)
  end

  def self.state_select
    [['有効','enabled'],['無効','disabled']]
  end

  def self.state_show(state)
    (self.state_select + [['deleted','削除済']]).rassoc(state).try(:first)
  end

  def self.place_for_select(selected = -1, place = :on)
    # スケジュール登録時のセレクトボックス生成。
    # Gw.options_for_selectでは、思い通りの物が作れなかったのでメソッドを新規作成
    # selected：デフォルトで選択されている要素を指定。int型
    # place：「「場所」に入力」を表示させるかを指定。on：表示、off：非表示
    places = []
    if place == :on
      places << ['', '', '']
      places << ['場所フィールドに入力したデータと同じ', 0, 0]
    end
    _items = self.where("state = ?", 'enabled').order('sort_no')
    _items.each do |_item|
      # 表示名、value、title
      places << [_item.place, _item.id, _item.prop_id]
    end

    idx = -1
    # main
    options_for_select = places.inject([]) do |options, element|
      idx += 1
      text, value, title = [element[0], element[1], element[2]]
      title = "title='#{title}'" unless title.blank?
      selected_attribute = ' selected="selected"' if value == selected
      options << %(<option value="#{Gw.html_escape(value.to_s)}"#{selected_attribute}#{title}>#{Gw.html_escape(text.to_s)}</option>)
    end
    options_for_select.join("\n")
  end

  private

  def set_creator
    self.created_uid = Core.user.id if Core.user
    self.created_gid = Core.user_group.id if Core.user_group
  end

  def set_updator
    self.updated_uid = Core.user.id if Core.user
    self.updated_gid = Core.user_group.id if Core.user_group
  end
end
