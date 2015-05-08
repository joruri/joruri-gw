class Gw::PortalAdd  < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gw::Model::Operator::UnameAndGid
  include Gw::Model::File::Base

  ACCEPT_FILE_EXTENSIONS = %w(.jpeg .jpg .png .gif)

  has_many :logs, :foreign_key => 'add_id', :class_name => 'Gw::PortalAddAccessLog'
  has_many :daily_accesses, :foreign_key => 'ad_id', :class_name => 'Gw::PortalAdDailyAccess'

  validates :title, :sort_no, :publish_start_at, :publish_end_at, presence: true
  validates :sort_no, numericality: true
  with_options if: lambda {|item| item.class_sso.to_i == 1} do |f|
    f.validates :url, presence: true
  end
  with_options if: lambda {|item| item.class_sso.to_i == 2} do |f|
    f.validates :url, :field_account, :field_pass, presence: true
  end
  validate :validate_publish_start_at_and_publish_end_at
  validate :validate_image_size

  default_scope -> { where.not(state: 'deleted') }

  def self.is_admin?(user = Core.user)
    user.has_role?('_admin/admin')
  end

  def class_external_label
    self.class.external_show(class_external)
  end

  def self.external_select
    [['内部',1],['外部',2]]
  end

  def self.external_show(class_external)
    external_select.rassoc(class_external).try(:first)
  end

  def pattern_select
    [['1',1],['2',2],['3',3],['4',4],['5',5]]
  end

  def self.pattern_show(class_pattern)
    self.new.pattern_select.rassoc(class_pattern).try(:first)
  end

  def is_large_select
    [['170 x 50',0],['170 x 160',1]]
  end

  def is_large_label
    is_large_select.rassoc(is_large).try(:first)
  end

  def class_sso_label
    self.class.sso_show(class_sso)
  end

  def self.sso_select
    [['URL','1'],['SSO','2']] + System::Product.available_sso_options
  end

  def self.sso_show(class_sso)
    sso_select.rassoc(class_sso).try(:first)
  end

  def published_label
    self.class.published_show(published)
  end

  def self.published_select
    [['公開','opened'],['非公開','closed']]
  end

  def self.published_show(published)
    published_select.rassoc(published).try(:first)
  end

  def place_label
    self.class.places_show(place)
  end

  def self.place_select(all=nil)
    places = [['ポータル左上',1],['ポータル下部',2],['リマインダー部分',3]]
    places = [['すべて',"0"]] + places if all == 'all'
    places
  end

  def self.places_show(place)
    place_select.rassoc(place).try(:first)
  end

  def self.publish_state(value)
    select = [['表示する', "opened"],['表示しない', "closed"] ]
    select.rassoc(value).try(:first)
  end

  def published_state
    if published == 'opened'
      if publish_end_at < Date.today
        'expired'
      elsif publish_start_at > Date.today
        'prepublic'
      else
        'opened'
      end
    else
      'closed'
    end
  end

  def published_display_style
    case published_state
    when 'prepublic' then 'color:#00f;'
    when 'expired', 'closed' then 'color:#f00;'
    end
  end

  def full_url
    case class_sso
    when '1'
      url
    when '2'
      "/_admin/gw/link_sso/#{id}/redirect_portal_adds"
    else
      "/_admin/gw/link_sso/redirect_to_joruri?to=#{class_sso}&path=#{CGI.escape(url)}"
    end
  end

  private

  def validate_publish_start_at_and_publish_end_at
    if self.publish_start_at && self.publish_end_at && self.publish_start_at >= self.publish_end_at
      errors.add(:publish_end_at, "は、#{locale(:publish_start_at)}より後の日付を入力してください。")
    end 
  end

  def validate_image_size
    return unless self.file

    case self.is_large
    when 1
      if (self.width > 170 || self.height > 160)
        errors.add(:file, 'は横170ピクセル×縦160ピクセル以内にしてください。')
      end
    else
      if (self.width > 170 || self.height > 50)
        errors.add(:file, 'は横170ピクセル×縦50ピクセル以内にしてください。')
      end
    end
  end
end
