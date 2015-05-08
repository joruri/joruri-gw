class Gw::MeetingGuideNotice < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gw::Model::Operator::Id

  validates :title, :sort_no, :state, :published, presence: true
  validates :title, length: { maximum: 82 }

  default_scope -> { where.not(state: 'deleted') }

  def published_label
    self.class.published_show(published)
  end

  def self.published_select
    [['公開','opened'],['非公開','closed']]
  end

  def self.published_show(published)
    published_select.rassoc(published).try(:first)
  end
end
