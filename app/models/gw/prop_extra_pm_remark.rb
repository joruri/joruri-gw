class Gw::PropExtraPmRemark < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates :state, presence: true
  validates :sort_no, presence: true
  validates :title, presence: true
  validates :url, presence: true

  def kind_options
    [['会議室',1],['レンタカー',2]]
  end

  def kind_label
    kind_options.rassoc(prop_class_id).try(:first)
  end

  def state_options
    [['表示する','enabled'],['表示しない','disabled']]
  end

  def state_label
    state_options.rassoc(state).try(:first)
  end
end
