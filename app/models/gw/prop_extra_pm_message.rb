class Gw::PropExtraPmMessage  < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates :state, :sort_no, :prop_class_id, :body, presence: true
  validates :sort_no, numericality: true
  validates :body, length: { maximum: 10000 }

  def state_select
    [['する',1],['しない',2]]
  end

  def state_show
    state_select.rassoc(state).try(:first)
  end

  def self.kind_select
     [["会議室",1], ["レンタカー",2]]
  end

  def self.search_select_props_class_ids
    [['すべて', '']] + kind_select
  end

  def kind_show
    self.class.kind_select.rassoc(prop_class_id).try(:first)
  end

  class << self
    def genres
      [["meetingroom",1], ["rentcar",2]]
    end

    def genre_to_class_id(genre)
      genres.assoc(genre).try(:last)
    end
  end
end
