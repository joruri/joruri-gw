class Gw::MeetingGuideNotice < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  before_create :set_creator
  before_update :set_updator

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
