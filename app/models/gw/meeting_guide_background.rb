class Gw::MeetingGuideBackground  < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gw::Model::File::Base

  ACCEPT_FILE_EXTENSIONS = %w(.jpeg .jpg .png .gif)

  before_create :set_creator
  before_update :set_updator

  validates :sort_no, :state, :published, :caption, :background_color, presence: true

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

  def background_color_label
    self.class.background_color_show(background_color)
  end

  def self.background_color_select
    #[['黒','black'],['青','blue'],['茶','brown'],['緑','green'],['オレンジ','orange'],['白','white']]
    [['白','white'], ['黒','black'], ['両方黒', 'all-black']]
  end

  def self.background_color_show(published)
    background_color_select.rassoc(published).try(:first)
  end

  def area_label
    self.class.background_area_show(area)
  end

  def self.background_area_select
    [['東部',1], ['南部',2], ['西部',3]]
  end

  def self.background_area_show(area_data)
    background_area_select.rassoc(area_data).try(:first)
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
