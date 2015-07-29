# encoding: utf-8
class Gw::EditLinkPiece < Gw::Database
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Base::Content

  belongs_to :parent, :class_name => 'Gw::EditLinkPiece', :foreign_key => :parent_id
  has_many :children, :class_name => 'Gw::EditLinkPiece', :foreign_key => :parent_id
  has_many :opened_children, :class_name => 'Gw::EditLinkPiece', :foreign_key => :parent_id,
    :conditions => "published = 'opened' and state != 'deleted'",
    :order => 'sort_no'
  belongs_to :css, :class_name => 'Gw::EditLinkPieceCss', :foreign_key => :block_css_id
  belongs_to :icon, :class_name => 'Gw::EditLinkPieceCss', :foreign_key => :block_icon_id

  validates_presence_of :name, :sort_no, :mode
  validates_presence_of :link_url,
    :if => lambda{|item| item.level_no == 4}
  validates_presence_of :field_account,
    :if => lambda{|item| item.class_sso == 2}
  validates_presence_of :field_pass,
    :if => lambda{|item| item.class_sso == 2}
  validates_presence_of :ssoid,
    :if => lambda{|item| item.class_sso == 2 && item.uid != nil}
  validates_presence_of :parent_id
  validates_uniqueness_of :sort_no, :scope=>:parent_id
  validate :validate_tab_keys

  before_create :set_creator
  before_update :set_updator

  def modes
    [['いつも',1], ['通常時',2], ['災害時',3]]
  end

  def mode_label
    modes.rassoc(mode).try(:first)
  end

  def self.is_dev?(uid = Site.user.id)
    System::Model::Role.get(1, uid ,'gwsub', 'developer')
  end

  def self.is_admin?(uid = Site.user.id)
    System::Model::Role.get(1, uid ,'edit_link_piece', 'admin')
  end

  def self.is_editor?(uid = Site.user.id)
    System::Model::Role.get(1, uid ,'edit_link_piece', 'editor')
  end

  def self.published_select
    published = [['公開','opened'],['非公開','closed']]
    return published
  end

  def self.published_show(published)
    publishes = [['closed','非公開'],['opened','公開']]
    show_str = publishes.assoc(published)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end

  def self.state_select
    status = [['有効','enabled'],['無効','disabled']]
    return status
  end

  def self.state_show(state)
    status = [['deleted','削除済'],['disabled','無効'],['enabled','有効']]
    show_str = status.assoc(state)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end

  def self.other_ctrl_select
    other_ctrls = [['する',1],['しない',2]]
    return other_ctrls
  end

  def self.other_ctrl_show(other_ctrl)
    other_ctrls = [[1,'する'],[2,'しない']]
    show_str = other_ctrls.assoc(other_ctrl)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end

  def self.external_select
    externals = [['内部',1],['外部',2]]
    return externals
  end

  def self.external_show(class_external)
    externals = [[1,'内部'],[2,'外部']]
    show_str = externals.assoc(class_external)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end

  def self.sso_select
    ssos = [['しない',1],['する',2]]
    return ssos
  end

  def self.sso_show(class_sso)
    ssos = [[1,'しない'],[2,'する']]
    show_str = ssos.assoc(class_sso)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end

  def self.level_show(level_no)
    level_str = [[1,'TOP'],[2,'ピース'],[3,'ブロック'],[4,'リンク']]
    show_str = level_str.assoc(level_no)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end

  def get_child(options={})
    if options[:published]
      cond  = "published = '#{options[:published]}' and state != 'deleted' and parent_id=#{self.id}"
    else
      cond  = "state != 'deleted' and parent_id=#{self.id}"
    end
    order = "sort_no"
    childrens = Gw::EditLinkPiece.find(:all , :conditions=>cond , :order => order )
    return childrens
  end

  def parent_tree
    Util::Tree.climb(id, :class => self.class)
  end
  
  def link_options
    options = {}
    
    if self.state == 'disabled' || (self.parent && self.parent.state == 'disabled')
      options[:url] = "#void"
      options[:disabled] = 'grayout'
    else
      if self.class_sso == 2
        options[:url] = "/_admin/gw/link_sso/#{self.id}/redirect_pref_pieces"
      else
        options[:url] = self.link_url
      end
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
  
  def self.swap(item1, item2)
    item1.sort_no, item2.sort_no = item2.sort_no, item1.sort_no
    item1.save(:validate => false)
    item2.save(:validate => false)
  end
  
protected
  
  def validate_tab_keys
    unless self.level_no == 2
      return true
    end
    if self.tab_keys.blank? || self.tab_keys == 0
      errors.add :tab_keys, 'は０以外の数値を入力してください。'
      return false
    end
    cond = "level_no=2 and tab_keys=#{self.tab_keys}"
    check = Gw::EditLinkPiece.find(:all,:conditions=>cond)
    if check.blank?
      return true
    else
      if check.size==1 and check[0].id==self.id
        return true
      end
      errors.add :tab_keys, 'はすでに登録されています。'
      return false
    end
    return true
  end

  def set_creator
    self.created_user   = Site.user.name
    self.created_group  = Site.user_group.name
  end

  def set_updator
    self.updated_user   = Site.user.name
    self.updated_group  = Site.user_group.name
  end
end