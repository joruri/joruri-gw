class Gw::EditTab < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Concerns::Gw::EditTab::PublicRole
  include Util::ValidateScript

  acts_as_tree dependent: :destroy

  has_many :opened_children, -> { where(published: "opened").order(:sort_no) }, :class_name => 'Gw::EditTab', :foreign_key => :parent_id
  has_many :public_roles, :foreign_key => :edit_tab_id, :class_name => 'Gw::EditTabPublicRole'

  accepts_nested_attributes_for :public_roles, allow_destroy: true

  before_create :set_default_values
  before_create :set_creator
  before_update :set_updator
  before_save :clear_needless_values

  validates :name, :sort_no, :is_public, presence: true
  with_options if: lambda {|item| item.class_sso.to_i == 2} do |f|
    f.validates :field_account, presence: true
    f.validates :field_pass, presence: true
  end
  with_options if: lambda {|item| item.is_public == 2} do |f|
    f.validates :display_auth, presence: true
  end
  with_options if: lambda {|item| item.other_controller_use.to_i == 1} do |f|
    f.validates :other_controller_url, presence: true
  end
  with_options if: lambda {|item| item.other_controller_use.to_i == 3} do |f|
    f.validates :link_url, presence: true
  end
  with_options if: lambda {|item| item.level_no == 2 && item.other_controller_use.to_i == 2} do |f|
    f.validates :tab_keys, presence: true, numericality: { only_integr: true, greater_than: 0 },
      uniqueness: { scope: [:parent_id, :deleted_at] }
  end

  validates_each :link_url do |record, attr, value|
    if value
      if record.class_sso.to_i == 2 && record.class_external.to_i == 2
        record.errors.add attr, 'の形式が正しくありません。' unless value =~ /^http[s]?\:\/\//
      end
     end
  end

  validate :check_script_name

  def check_script_name
    errors.add(:name, "にスクリプトは利用できません。") if check_script(name)
  end
  default_scope { where.not(state: 'deleted') }
  scope :preload_opened_children, -> {
    preload([:parent, :opened_children => [:parent, :opened_children => :parent]])
  }

  def self.is_dev?(user = Core.user)
    user.has_role?('gwsub/developer')
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('edit_tab/admin', '_admin/admin')
  end

  def self.is_editor?(user = Core.user)
    user.has_role?('edit_tab/editor')
  end

  def published_label
    self.class.published_show(published)
  end

  def self.published_select
    [['公開','opened'],['非公開','closed']]
  end

  def self.published_show(published)
    self.published_select.rassoc(published).try(:first)
  end

  def state_label
    self.class.state_show(state)
  end

  def self.state_select
    [['有効','enabled'],['無効','disabled']]
  end

  def self.state_show(state)
    status = self.state_select + ['削除済','deleted']
    status.rassoc(state).try(:first)
  end

  def other_controller_use_label
    self.class.other_ctrl_show(other_controller_use)
  end

  def self.other_ctrl_select
    [['タブキー','2'],['個別割当URL','1'],['SSO','3']] + System::Product.available_sso_options
  end

  def self.other_ctrl_show(other_ctrl)
    self.other_ctrl_select.rassoc(other_ctrl).try(:first)
  end

  def class_external_label
    self.class.external_show(class_external)
  end

  def self.external_select
    [['リンクなし',0],['内部',1],['外部',2]]
  end

  def self.external_show(class_external)
    self.external_select.rassoc(class_external).try(:first)
  end

  def is_public_label
    self.class.is_public_show(is_public)
  end

  def self.public_select
    [['すべて',0],['所属制限',1],['関数指定',2]]
  end

  def self.is_public_show(is_public)
    self.public_select.rassoc(is_public).try(:first)
  end

  def class_sso_label
    self.class.sso_show(class_sso)
  end

  def self.sso_select
    [['URL','1'],['SSO','2']] + System::Product.available_sso_options
  end

  def self.sso_show(class_sso)
    self.sso_select.rassoc(class_sso).try(:first)
  end

  def level_no_label
    self.class.level_show(level_no)
  end

  def self.level_show(level_no)
    [[1,'TOP'],[2,'タブ'],[3,'ブロック'],[4,'リンク']].assoc(level_no).try(:last)
  end

  def is_public?(user = Core.user)
    case self.is_public
    when nil, 0 then true
    when 1 then has_public_group?(user)
    when 2 then has_display_auth?(user)
    else false
    end
  end

  def full_url
    if self.level_no == 2
      self.full_url_by_other_controller_use
    else
      self.full_url_by_class_sso
    end
  end

  def link_options
    options = {}

    if self.state == 'disabled' || (self.parent && self.parent.state == 'disabled')
      options[:url] = "#void"
      options[:disabled] = 'grayout'
    else
      options[:url] = full_url
    end

    case self.class_external
    when 1
      options[:target] = '_self';
    when 2
      options[:target] = '_blank';
      options[:class_ext] = 'ext';
    end

    if self.icon_path.present? && FileTest.exist?("#{Rails.root}/public/#{self.icon_path}")
      options[:icon_path] = self.icon_path
    end

    options
  end

protected

  def has_public_group?(user)
    user_gids = user.groups.map(&:id)
    public_gids = self.public_roles.preload(:group => [:parent, :enabled_children => [:parent, :enabled_children]])
      .map(&:group).compact
      .map(&:self_and_enabled_descendants).flatten
      .map(&:id)
    (user_gids & public_gids).present?
  end

  def has_display_auth?(user)
    if self.display_auth.present?
      eval(self.display_auth)
    else
      true
    end
  rescue SyntaxError, ScriptError, StandardError
    false
  end

  def full_url_by_class_sso
    case class_sso
    when '1'
      link_url
    when '2'
      "/_admin/gw/link_sso/#{id}/redirect_tab"
    else
      "/_admin/gw/link_sso/redirect_to_joruri?to=#{class_sso}&path=#{CGI.escape(link_url)}"
    end
  end

  def full_url_by_other_controller_use
    case other_controller_use
    when '1'
      other_controller_url
    when '2'
      "/tab_main/#{self.tab_keys}"
    when '3'
      "/_admin/gw/link_sso/#{self.id}/redirect_tab"
    else
      "/_admin/gw/link_sso/redirect_to_joruri?to=#{other_controller_use}&path=#{CGI.escape(link_url)}"
    end
  end

  def set_creator
    self.created_user   = Core.user.name if Core.user
    self.created_group  = Core.user_group.name if Core.user_group
  end

  def set_updator
    self.updated_user   = Core.user.name if Core.user
    self.updated_group  = Core.user_group.name if Core.user_group
  end

  def set_default_values
    self.is_public ||= 0
  end

  def clear_needless_values
    if self.is_public != 2
      self.display_auth = nil
    end
  end
end
