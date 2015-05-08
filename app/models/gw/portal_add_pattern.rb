class Gw::PortalAddPattern < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gw::Model::Operator::UnameAndGid

  attr_accessor :skip_validate_size

  has_many :group_patterns, :foreign_key => :group_id, :primary_key => :group_id, :class_name => self.name
  belongs_to :add, :foreign_key => :add_id, :class_name => 'Gw::PortalAdd'

  accepts_nested_attributes_for :group_patterns, allow_destroy: true

  validates :sort_no, presence: true, numericality: true
  validates :title, presence: true
  validates :group_id, presence: true
  validate :validate_size, unless: :skip_validate_size
  validate :validate_place

  def pattern_select
    [['2',2],['3',3],['4',4],['5',5]]
  end

  def pattern_show
    pattern_select.rassoc(pattern.to_i).try(:first)
  end

  def place_select
    [['ポータル下部',2],['リマインダー部分',3]]
  end

  def place_show
    place_select.rassoc(place.to_i).try(:first)
  end

  def state_select
    [['有効','enabled'],['無効','disabled']]
  end

  def state_show
    state_select.rassoc(state).try(:first)
  end

  private

  def limit_for_pattern_and_place
    case pattern
    when 2 then 8
    when 3 then place == 2 ? 8 : 6
    when 4 then 7
    when 5 then place == 2 ? 8 : nil
    else 6
    end
  end

  def validate_size
    patterns = group_patterns.reject(&:marked_for_destruction?)

    if patterns.size == 0
      errors.add(:base, "広告を選択してください。")
    end

    limit = limit_for_pattern_and_place
    if limit && patterns.size > limit
      errors.add(:base, "広告の登録件数が上限を超えています。")
    end
  end

  def validate_place
    if pattern == 2 && place == 3
      errors.add(:place, "：　表示形式が「パターン2」の場合、表示場所に「リマインダー部分」を選択できません。")
    end
  end
end
