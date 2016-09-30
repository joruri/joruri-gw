require 'date'
class System::Group < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree
  extend ActsAsTree::TreeWalker

  acts_as_tree order: { sort_no: :asc, code: :asc }, dependent: :destroy

  has_many :enabled_children, -> { where(:state => 'enabled').order(:sort_no, :code) }, :foreign_key => :parent_id, :class_name => 'System::Group'
  has_many :user_group, :foreign_key => :group_id,  :class_name => 'System::UsersGroup'
  has_many :users, -> { order(System::UsersGroup.arel_table[:job_order], System::User.arel_table[:name_en]) }, :through => :user_group, :source => :user

  validates_presence_of :state, :code, :name, :start_at
  validates_uniqueness_of :code, :scope => [:parent_id]
  validates_numericality_of :sort_no

  validates_each :state do |record, attr, value|
    if value.present?
      record.errors.add attr, 'は、上位所属が「無効」のため、「有効」に変更できません。' if !record.parent.blank? && record.parent.state == "disabled" && record.state == "enabled"
    end
  end
  validates_each :end_at do |record, attr, value|
    if value.present?
      record.errors.add attr, 'は、状態が「有効」の場合、空欄としてください。' if record.state == "enabled"
      record.errors.add attr, 'には、適用開始日より後の日付を入力してください。' if Time.local(value.year, value.month, value.day, 0, 0, 0) < Time.local(record.start_at.year, record.start_at.month, record.start_at.day, 0, 0, 0)
      record.errors.add attr, 'には、本日以前の日付を入力してください。'  if Time.local(value.year, value.month, value.day, 0, 0, 0) > Time.local(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0)
    end
  end


  validates_each :code do |record, attr, value|
    if value.present? && System::User.valid_user_code_characters?(value) == false
      record.errors.add attr, "は、半角英数字、および半角アンダーバーのみのデータとしてください。"
    end
  end
  validates_each :start_at do |record, attr, value|
    if value.present?
      record.errors.add attr, 'には、本日以前の日付を入力してください。'  if Time.local(value.year, value.month, value.day, 0, 0, 0) > Time.local(Time.now.year, Time.now.month, Time.now.day, 0, 0, 0)
    end
  end

  after_save :save_group_history, :clear_cache
  before_destroy :clear_cache

  def ou_name
    code.to_s + name
  end

  def display_name
    name
  end

  def tree_name
    if level_no >= 2
      "　　"*(level_no-2) + "(#{code})#{name}"
    else
      "(#{code})#{name}"
    end
  end

  def self.state_options
    [['有効','enabled'],['無効','disabled']]
  end

  def self.ldap_options
    [['非同期',0],['同期',1]]
  end

  def self.ldap_show(ldap)
    ldap_options.rassoc(ldap.to_i).try(:first)
  end

  def self.usable?(g_id,day=nil)
    return false if g_id==nil
    return false if g_id.to_i==0
    day   = Time.now     if day==nil
    g = System::Group.find(g_id)

    if g.start_at <= day && g.end_at==nil
      return true
    end
    if g.start_at <= day && day < g.end_at
      return true
    end
    return false
  end

  def self.level_show(level_no)
    if level_no == 1
      return "root"
    elsif level_no == 2
      return "部局"
    elsif level_no == 3
      return "所属"
    end
  end

  def self.get_gid(u_id = Core.user.id , day=nil)
    if day==nil
      ug_order  = "user_id ASC  , job_order ASC , start_at DESC "
      ug_cond   = "user_id = #{u_id} and job_order=0 and start_at <= '#{Date.today} 00:00:00' and (end_at IS null or end_at = '0000-00-00 00:00' or end_at > '#{Date.today} 00:00:00')"
      user_group = System::UsersGroup.where(ug_cond).order(ug_order)
      if user_group.blank?
        return Core.user_group.id
      else
        return user_group[0].group_id
      end
    else
      ug_order  = "user_id ASC , start_at DESC , job_order ASC"
      ug_cond   = "user_id = #{u_id} and job_order=0 and start_at < #{day}"
      user_group = System::UsersGroup.where(ug_cond).order(ug_order)
      return nil if user_group.blank?
      user_group.each do |g|
        return g.id if System::Group.usable?(g.id , nil)==true
      end
      return nil
    end
  end

  def self.get_level2_groups
    System::Group.where(:level_no => 2).order(:code, :sort_no, :id)
  end

  def self.get_groups(user = Core.user)
    g_cond = "user_id=#{user.id}"
    g_order= "user_id ASC,start_at DESC"
    u_groups = System::UsersGroup.where(g_cond).order(g_order)
    return nil if u_groups.blank?
    groups = []
    u_groups.each do |ug|
      groups << System::Group.find(ug.group_id)
    end
    return groups
  end

  def self.select_dd_group(day=nil,level=nil,parent_id=nil,all=nil)
    day   = Time.now     if day==nil
    dd_lists = []
    dd_lists << ['すべて',0] if all == 'all'
    if parent_id ==nil
      if level==nil
        dd_lists = System::Group.self.select_dd_tree(all)
      else

      end
    else

      g_order="code ASC , start_at DESC"
      g_cond="parent_id='#{parent_id}' and state = 'enabled'"
      groups = System::Group.where(g_cond).order(g_order)
      groups.each do |g|
        next if System::Group.usable?(g.id , "#{day}" )==false
        dd_lists << ['('+g.code+')'+g.name,g.id]
      end unless groups.blank?
    end
  end

  def self.select_dd_tree(all=nil)
    dd_lists = []
    dd_lists << ['すべて',0] if all == 'all'
    roots = System::Group.where("level_no=1 and state='enabled'")
    roots.each do |r|
      dd_lists << ['('+r.code+')'+r.name,r.id]
      dd_lists = System::Group.get_childs(dd_lists,r)
    end
    return dd_lists
  end

  def self.get_childs(dd_lists,parent)
    c_lists = dd_lists
    childs = System::Group.where("state='enabled' and parent_id=#{parent.id}").order('sort_no')
    return c_lists if childs.blank?
    pad_str = "　"*(parent.level_no.to_i-1)*2+"+"+"-"*(parent.level_no.to_i)*2
    childs.each do |c|
      c_lists << [pad_str+'('+c.code+')'+c.name,c.id]
      c_lists = System::Group.get_childs(c_lists,c)
    end
    return c_lists
  end

  def self.select_dd_tree2(all=nil)
    dd_lists = []
    dd_lists << ['すべて',0] if all == 'all'
    roots = System::Group.where("level_no=2 and state='enabled'" ,:order=>'sort_no').order('sort_no')
    roots.each do |r|
      dd_lists << ['('+r.code+')'+r.name,r.id]
      dd_lists = System::Group.get_childs(dd_lists,r)
    end
    return dd_lists
  end

  def self.get_group_tree(_group_id)
    _groups = []

    if _group_id.blank?
        _dept_conditions =  "state = 'enabled'"
        _dept_conditions << " and level_no = 2"
        _dept_conditions << " and parent_id = 1"
        _dep_order = "code ASC"
        _departments = System::Group.where(_dept_conditions).order(_dep_order)

        _departments.each do | _dep |

        _groups << _dep
            _sec_conditions =  "state = 'enabled'"
            _sec_conditions << " and level_no = 3"
            _sec_conditions << " and parent_id = #{_dep.id}"
            _sec_order = "code ASC"
            _sections = System::Group.where(_sec_conditions).order(_sec_order)

            _sections.each do | _sec |
                _groups << _sec
            end
        end
    else
        _dep = System::Group.find(_group_id)
        _groups << _dep
        if _dep.level_no == 2
            _sec_conditions =  "state = 'enabled'"
            _sec_conditions << " and level_no = 3"
            _sec_conditions << " and parent_id = #{_dep.id}"
            _sec_order = "code ASC"
            _sections = System::Group.where(_sec_conditions).order(_sec_order)

            _sections.each do | _sec |
                _groups << _sec
            end
        end
    end
    return _groups
  end

  def self.get_group_select(all=nil, prefix='', options={})
    selects = []
    selects << ['すべて',0] if all=='all'
    selects << ['制限なし',0] if all=='nolimit'
    cond = ''
    cond += ' AND ' + options[:add_conditions] if !options[:add_conditions].blank?
    groups_select = System::Group.where("state='enabled' " + cond).order('code, sort_no, name')
    selects += groups_select.map{|group| [ Gw.trim(group.ou_name), prefix+group.id.to_s]}
    return selects
  end

  def csvget_data
    csv = Array.new
    csv << System::UsersGroup.state_show(self.state)
    csv << "group"
    csv << System::Group.level_show(self.level_no)
    csv << self.parent.try(:code)
    csv << self.code
    csv << System::UsersGroup.ldap_show(self.ldap)
    csv << ""
    csv << self.name
    csv << self.name_en
    csv << ""
    csv << ""
    csv << ""
    csv << ""
    csv << self.email
    csv << ""
    csv << ""
    csv << Gw.date_str(self.start_at)
    csv << Gw.date_str(self.end_at)
    return csv
  end

  def self_and_enabled_children
    [self] + enabled_children
  end

  def enabled_descendants(arr = [])
    enabled_children.each {|g| arr << g; g.enabled_descendants(arr) }
    arr
  end

  def self_and_enabled_descendants(arr = [])
    arr << self
    enabled_children.each {|g| g.self_and_enabled_descendants(arr) }
    arr
  end

  def enabled_users_for_options(options = {})
    us = users.select(:id, :code, :name).where(state: 'enabled')
      .where.not(id: Gw::PropTypesUser.select(:user_id))
      .reorder(:code)
    us = us.where(ldap: 1) if options[:ldap] == 1 && Joruri.config.application['system.show_only_ldap_user']
    us
  end

  def enabled_user_options(options = {})
    enabled_users_for_options(options).map {|u| [Gw.trim(u.display_name), u.id] }
  end

  def enabled_group_options(options = {})
    enabled_descendants.map{|g| ["　　"*(g.level_no-self.level_no-1) + "(#{g.code})#{g.name}", g.id]}
  end

  def self.enabled_group_options
    self.select(:id, :code, :name, :level_no)
      .where(state: 'enabled').where.not(level_no: 1)
      .order(:sort_no, :code, :name).map{|g| [g.tree_name, g.id]}
  end

  def self.enabled_group_options_without_leaf
    max_level = self.maximum(:level_no)
    self.select(:id, :code, :name, :level_no)
      .where(state: 'enabled').where.not(level_no: [1, max_level])
      .order(:sort_no, :code, :name).map{|g| [g.tree_name, g.id]}
  end

private

  def clear_cache
    Rails.cache.clear
  end

  def save_group_history
    group_history = System::GroupHistory.where(:id =>self.id).first
    if group_history.blank?
      group_history = System::GroupHistory.new
      group_history.id = self.id
    end
    group_history.attributes = self.attributes.delete_if{|k,v| k == 'id'}
    group_history.save
  end

end
