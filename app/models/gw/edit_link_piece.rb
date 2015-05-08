class Gw::EditLinkPiece < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gw::Model::Operator::Name
  include Gw::Model::Cache::EditLinkPiece

  acts_as_tree dependent: :destroy

  has_many :opened_children, -> { where(published: "opened").order(:sort_no) }, :class_name => 'Gw::EditLinkPiece', :foreign_key => :parent_id
  belongs_to :css, :class_name => 'Gw::EditLinkPieceCss', :foreign_key => :block_css_id
  belongs_to :icon, :class_name => 'Gw::EditLinkPieceCss', :foreign_key => :block_icon_id

  validates :name, :sort_no, :mode, presence: true
  with_options if: lambda {|item| item.class_sso.to_i == 2} do |f|
    f.validates :field_account, presence: true
    f.validates :field_pass, presence: true
  end
  with_options if: lambda {|item| item.level_no == 2} do |f|
    f.validates :tab_keys, presence: true, numericality: { only_integr: true, greater_than: 0 }, 
      uniqueness: { scope: [:parent_id, :deleted_at] }
  end

  default_scope { where.not(state: 'deleted') }
  scope :preload_opened_children, -> {
    preload([:css, :icon, :parent, :opened_children => [:css, :icon, :parent, :opened_children => [:css, :icon, :parent]]])
  }

  def modes
    [['いつも',1], ['通常時',2], ['災害時',3]]
  end

  def mode_label
    modes.rassoc(mode).try(:first)
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

  def state_label
    self.class.state_show(state)
  end

  def self.state_select
    [['有効','enabled'],['無効','disabled']]
  end

  def self.state_show(state)
    status = state_select + ['削除済','deleted']
    status.rassoc(state).try(:first)
  end

  def other_controller_use_label
    self.class.other_ctrl_show(other_controller_use)
  end

  def self.other_ctrl_select
    [['する',1],['しない',2]]
  end

  def self.other_ctrl_show(other_ctrl)
    other_ctrl_select.rassoc(other_ctrl).try(:first)
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

  def class_sso_label
    self.class.sso_show(class_sso)
  end

  def self.sso_select
    [['URL','1'],['SSO','2']] + System::Product.available_sso_options
  end

  def self.sso_show(class_sso)
    sso_select.rassoc(class_sso).try(:first)
  end

  def level_no_label
    self.class.level_show(level_no)
  end

  def self.level_no_options
    [['TOP',1],['ピース',2],['ブロック',3],['リンク',4]]
  end

  def self.level_show(level_no)
    level_no_options.rassoc(level_no).try(:first)
  end

  def link_options
    options = {}

    if self.state == 'disabled' || (self.parent && self.parent.state == 'disabled')
      options[:url] = "#void"
      options[:disabled] = 'grayout'
    else
      options[:url] = full_url
    end

    if self.class_external == 2
      options[:target] = '_blank';
    else
      options[:target] = '_self';
    end

    if self.css && self.css.state == 'enabled'
      options[:css_class] = self.css.css_class
    end

    if self.icon && self.icon.state == 'enabled'
      options[:icon_class] = self.icon.css_class
    end

    if self.icon_path.present? && FileTest.exist?("#{Rails.root}/public/#{self.icon_path}")
      options[:icon_path] = self.icon_path
    end

    options
  end

  def full_url
    case class_sso
    when '1'
      link_url
    when '2'
      "/_admin/gw/link_sso/#{id}/redirect_link_piece"
    else
      "/_admin/gw/link_sso/redirect_to_joruri?to=#{class_sso}&path=#{CGI.escape(link_url)}"
    end
  end

  def self.is_dev?(user = Core.user)
    user.has_role?('gwsub/developer')
  end

  def self.is_admin?(user = Core.user)
    user.has_role?('edit_link_piece/admin')
  end

  def self.is_editor?(user = Core.user)
    user.has_role?('edit_link_piece/editor')
  end

  def deleted?
    return self.state == 'deleted'
  end

  def has_display_auth?
    if self.display_auth.present?
      begin
        return eval(self.display_auth)
      rescue SyntaxError, ScriptError, StandardError
        return false
      end
    end
    return true
  end
end
