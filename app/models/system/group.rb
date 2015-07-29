# encoding: utf-8
require 'date'
class System::Group < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config
  include System::Model::Tree
  include System::Model::Base::Content

  belongs_to :status,     :foreign_key => :state,     :class_name => 'System::Base::Status'
  belongs_to :parent,     :foreign_key => :parent_id, :class_name => 'System::Group'
  has_many :children ,  :foreign_key => :parent_id, :class_name => 'System::Group'
  has_many :enabled_children  , :foreign_key => :parent_id, :class_name => 'System::Group',
    :conditions => {:state => 'enabled'}, :order => :sort_no
  has_many :user_group, :foreign_key => :group_id,  :class_name => 'System::UsersGroup'
  has_and_belongs_to_many :users, :class_name => 'System::User',
    :join_table => 'system_users_groups', :order => 'job_order,system_users.name_en'

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

  def clear_cache
    Rails.cache.clear
  end

  def save_group_history
    group_history = System::GroupHistory.find_by_id(self.id)
    if group_history.blank?
      group_history = System::GroupHistory.new
      group_history.id = self.id
    end
    group_history.attributes = self.attributes.delete_if{|k,v| k == 'id'}
    group_history.save
  end

  def ou_name
    code.to_s + name
  end

  def display_name
    name
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

  def self.get_gid(u_id = Site.user.id , day=nil)
    if day==nil
      ug_order  = "user_id ASC  , job_order ASC , start_at DESC "
      ug_cond   = "user_id = #{u_id} and job_order=0 and start_at <= '#{Date.today} 00:00:00' and (end_at IS null or end_at = '0000-00-00 00:00' or end_at > '#{Date.today} 00:00:00')"
      user_group = System::UsersGroup.find(:all , :conditions=> ug_cond ,:order => ug_order)
      if user_group.blank?
        return Site.user_group.id
      else
        return user_group[0].group_id
      end
    else
      ug_order  = "user_id ASC , start_at DESC , job_order ASC"
      ug_cond   = "user_id = #{u_id} and job_order=0 and start_at < #{day}"
      user_group = System::UsersGroup.find(:all , :conditions=> ug_cond ,:order => ug_order)
      return nil if user_group.blank?
      user_group.each do |g|
        return g.id if System::Group.usable?(g.id , nil)==true
      end
      return nil
    end
  end

  def self.get_level2_groups
    group = System::Group.new
    cond  = "level_no = 2"
    order = "code, sort_no, id"
    groups = group.find(:all, :order=>order, :conditions=>cond)
    return groups
  end

  def self.get_groups(user = Site.user)
    g_cond = "user_id=#{user.id}"
    g_order= "user_id ASC,start_at DESC"
    u_groups = System::UsersGroup.find(:all,:conditions=>g_cond,:order=>g_order)
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
      groups = System::Group.find(:all,:conditions=>g_cond,:orde=>g_order)
      groups.each do |g|
        next if System::Group.usable?(g.id , "#{day}" )==false
        dd_lists << ['('+g.code+')'+g.name,g.id]
      end unless groups.blank?
    end
  end

  def self.select_dd_tree(all=nil)
    dd_lists = []
    dd_lists << ['すべて',0] if all == 'all'
    roots = System::Group.find(:all,:conditions=>"level_no=1 and state='enabled'")
    roots.each do |r|
      dd_lists << ['('+r.code+')'+r.name,r.id]
      dd_lists = System::Group.get_childs(dd_lists,r)
    end
    return dd_lists
  end

  def self.get_childs(dd_lists,parent)
    c_lists = dd_lists
    childs = System::Group.find(:all,:conditions=>"state='enabled' and parent_id=#{parent.id}" ,:order=>'sort_no')
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
    roots = System::Group.find(:all,:conditions=>"level_no=2 and state='enabled'" ,:order=>'sort_no')
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
        _departments = System::Group.find(:all , :conditions => _dept_conditions ,:order => _dep_order )

        _departments.each do | _dep |

        _groups << _dep
            _sec_conditions =  "state = 'enabled'"
            _sec_conditions << " and level_no = 3"
            _sec_conditions << " and parent_id = #{_dep.id}"
            _sec_order = "code ASC"
            _sections = System::Group.find(:all , :conditions => _sec_conditions ,:order => _sec_order )

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
            _sections = System::Group.find(:all , :conditions => _sec_conditions ,:order => _sec_order )

            _sections.each do | _sec |
                _groups << _sec
            end
        end
    end
    return _groups
  end

  def self.ldap_show(ldap)
    ldap_state = []
    ldaps = Gw.yaml_to_array_for_select 'system_users_ldaps'
    ldaps.each do |value , key|
      ldap_state << [key,value]
    end
    ldap_str = ldap_state.assoc(ldap.to_i)
    return ldap_str[1]
  end

  def self.truncate_table
    connect = self.connection()
    truncate_query = "TRUNCATE TABLE `system_groups` ;"
    connect.execute(truncate_query)
  end

  def self.get_group_select(all=nil, prefix='', options={})
    selects = []
    selects << ['すべて',0] if all=='all'
    selects << ['制限なし',0] if all=='nolimit'
    cond = ''
    cond += ' AND ' + options[:add_conditions] if !options[:add_conditions].blank?
    groups_select = System::Group.find(:all,
      :conditions=>"state='enabled' " + cond,
      :order=>'code, sort_no, name')
    selects += groups_select.map{|group| [ Gw.trim(group.ou_name), prefix+group.id.to_s]}
    return selects
  end

  def csvget_data
    csv = Array.new
    csv << System::UsersGroup.state_show(self.state)
    csv << "group"
    csv << System::Group.level_show(self.level_no)
    csv << self.parent.code
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
end
