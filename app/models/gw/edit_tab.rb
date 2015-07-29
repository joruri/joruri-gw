# encoding: utf-8
class Gw::EditTab < Gw::Database
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Base::Content

  belongs_to :parent, :class_name => 'Gw::EditTab', :foreign_key => :parent_id

  has_many :children, :class_name => 'Gw::EditTab', :foreign_key => :parent_id
  has_many :opened_children, :class_name => 'Gw::EditTab', :foreign_key => :parent_id,
    :conditions => "published = 'opened' and state != 'deleted'",
    :order => "sort_no"
  has_many :public_roles, :foreign_key => :edit_tab_id, :class_name => 'Gw::EditTabPublicRole'

  validates_presence_of :name, :sort_no, :is_public
  validates_presence_of :field_account,
    :if => Proc.new{ |item| item.class_sso == 2 }
  validates_presence_of :field_pass, 
    :if => Proc.new{ |item| item.class_sso == 2 }
  validates_presence_of :display_auth, 
    :if => Proc.new{ |item| item.is_public == 2 }
  validates_uniqueness_of :sort_no, :scope=>:parent_id
  validate :validate_tab_keys

  before_create :set_creator
  before_update :set_updator

  def self.is_dev?(uid = Site.user.id)
    role_dev  = System::Model::Role.get(1, uid ,'gwsub', 'developer')
    return role_dev
  end

  def self.is_admin?(uid = Site.user.id)
    edit_tab_admin  = System::Model::Role.get(1, uid ,'edit_tab', 'admin')
    admin_admin     = System::Model::Role.get(1, uid ,'_admin', 'admin')
    role_admin = admin_admin || edit_tab_admin
    return role_admin
  end

  def self.is_editor?(uid = Site.user.id)
    role_editor = System::Model::Role.get(1, uid ,'edit_tab', 'editor')
    return role_editor
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
    externals = [['リンクなし',0],['内部',1],['外部',2]]
    return externals
  end

  def self.external_show(class_external)
    externals = [[0,'リンクなし'],[1,'内部'],[2,'外部']]
    show_str = externals.assoc(class_external)
    if show_str.blank?
      return nil
    else
      return show_str[1]
    end
  end

  def self.public_select
    externals = [['すべて',0],['所属制限',1],['関数指定',2]]
    return externals
  end

  def self.is_public_show(is_public)
    is_public_items = [[0, 'すべて'],[1, '所属制限'],[2, '関数指定']]
    show = is_public_items.assoc(is_public)
    if show.blank?
      return nil
    else
      return show[1]
    end
  end

  def public_groups_display
    gids = Array.new
    ret = Array.new
    _delete_ret = Array.new

    self.public_roles.each do |public_role|
      if public_role.class_id == 2
        gids << public_role.uid
      end
    end

    parent_groups = System::GroupHistory.new.find(:all, :conditions =>"level_no = 2", :order=>"sort_no , code, start_at DESC, end_at IS Null ,end_at DESC")
    groups = System::GroupHistory.new.find(:all, :conditions => ["id in (?)", gids], :order=>"level_no,  sort_no , code, start_at DESC, end_at IS Null ,end_at DESC")

    parent_groups.each do |parent_group|
      groups.each do |group|
        g = System::Group.find_by_id(group.id)
        if !g.blank?
          if g.id == parent_group.id
            ret << [g.name]
          elsif g.parent_id == parent_group.id
            if g.state == "disabled"
              ret << "<span class=\"required\">#{g.name}</span>"
            else
              ret << [g.name]
            end
          end
        else
          _delete_ret << "<span class=\"required\">削除所属 gid=#{group.id}</span>"
        end
      end
    end

    _delete_ret = _delete_ret.sort.uniq

    ret = ret + _delete_ret

    return ret
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
    level_str = [[1,'TOP'],[2,'タブ'],[3,'ブロック'],[4,'リンク']]
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
    childrens = Gw::EditTab.find(:all , :conditions=>cond , :order => order )
    return childrens
  end

  def parent_tree
    Util::Tree.climb(id, :class => self.class)
  end

  def save_with_rels(params, mode, options={})

    par_item = params[:item].dup
    if par_item.key?(:public_groups_json)
      par_item.delete :public_groups
      public_groups = ::JsonParser.new.parse(par_item[:public_groups_json])
      par_item.delete :public_groups_json
    end

    par_item[:is_public] == '0' if par_item[:is_public].blank?

    if par_item[:is_public] == '1'
      par_item[:display_auth] = nil
    elsif par_item[:is_public] == '2'
    elsif par_item[:is_public] == '0'
      par_item[:display_auth] = nil
    end

    self.attributes = par_item

    if mode == :update
      save_flg = self.errors.size == 0 && self.editable? && self.save()
    elsif mode == :create
      save_flg = self.errors.size == 0 && self.creatable? && self.save()
    end

    if save_flg
      edit_tab_id = self.id
      if par_item[:is_public] == '1'

        old_public_groups = Gw::EditTabPublicRole.find(:all, :conditions=>["edit_tab_id = ? and class_id = ?", edit_tab_id, 2])
        old_public_groups.each_with_index{|old_public_group, x|
          use = 0
          public_groups.each_with_index{|public_group, y|
            if old_public_group.uid.to_s == public_group[1].to_s
                public_groups.delete_at(y)
                use = 1
            end
          }
          if use == 0
            old_public_group.destroy
          end
        }
        public_groups.each_with_index{|_public_group, y|
          new_group_role = Gw::EditTabPublicRole.new()
          new_group_role.uid = _public_group[1]
          new_group_role.edit_tab_id = edit_tab_id
          new_group_role.class_id = 2
          new_group_role.created_at = 'now()'
          new_group_role.updated_at = 'now()'
          new_group_role.save
        }
      elsif par_item[:is_public] == '2'
        Gw::EditTabPublicRole.destroy_all(["edit_tab_id = ? and class_id = ?", edit_tab_id, 2]) # 「すべて」が選択された場合、所属制限をすべて削除
      elsif par_item[:is_public] == '0'
        Gw::EditTabPublicRole.destroy_all(["edit_tab_id = ? and class_id = ?", edit_tab_id, 2]) # 「すべて」が選択された場合、所属制限をすべて削除
        par_item.delete :display_auth
      end
      return true
    else
      return false
    end
  end

  def is_public?(gid = Site.user_group.id)

    if self.is_public == 0 || self.is_public.blank?
      return true
    elsif self.is_public == 1
      gids = Array.new
      self.public_roles.each do |role|
        if role.class_id == 2
          role_group = role.group
          unless role_group.blank?
            if role_group.level_no == 2
              role_group.children.each do |children|
                gids << children.id
              end
            else
              gids << role_group.id
            end
          end
        end
      end
      gids = gids.sort.uniq
      if gids.index(gid).nil?
        return false
      else
        return true
      end
    elsif self.is_public == 2

      display_auth = self.display_auth
      if display_auth.blank?
        display_auth = display_auth.strip
      end

      if !display_auth.blank?
        begin
          return eval(display_auth)
        rescue SyntaxError, ScriptError, StandardError
          return false
        end
      else
        return true
      end
    else
      return false
    end
  end
  
  def link_options
    options = {}
    
    if self.state == 'disabled' || (self.parent && self.parent.state == 'disabled')
      options[:url] = "#void"
      options[:disabled] = 'grayout'
    else
      if self.class_external != 0
        if self.class_sso == 2
          options[:url] = "/_admin/gw/link_sso/#{self.id}/redirect_pref_pieces?src=tab"
        else
          options[:url] = self.link_url
        end
      end
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
  
  def validate_tab_keys
    unless self.level_no == 2
      return true
    end
    if self.tab_keys.blank? || self.tab_keys == 0
      errors.add :tab_keys, 'は０以外の数値を入力してください。'
      return false
    end
    cond = "level_no=2 and tab_keys=#{self.tab_keys}"
    check = Gw::EditTab.find(:all,:conditions=>cond)
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
