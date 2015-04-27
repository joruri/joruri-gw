class System::GroupHistory < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree

  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'System::GroupHistory'
  has_many :user_group, :foreign_key => :group_id,  :class_name => 'System::UsersGroupHistory'
  has_many :users, -> { order(System::UsersGroupHistory.arel_table[:job_order], System::User.arel_table[:name_en]) }, :through => :user_group, :source => :user

  validates_presence_of :state,:code,:name,:start_at
  validates_uniqueness_of :code, :scope => [:parent_id, :start_at]
  validates_each :end_at do |record, attr, value|
    record.errors.add attr, 'には、適用開始日より後の日付を入力してください'  if value.blank? ? false : (value <= record.start_at)
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v, :code,:name,:name_en,:e_main
      end
    end if params.size != 0

    return self
  end
  require 'date'

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
    g = System::GroupHistory.find(g_id)

    if g.start_at <= day && g.end_at==nil
      return true
    end
    if g.start_at <= day && day < g.end_at
      return true
    end
    return false
  end

  def self.group_states(state)
    show_status(state)
  end

  def self.show_status(state)
    I18n.t('enum.system/group.state').stringify_keys[state]
  end

  def self.get_gid(u_id = Core.user.id , day=nil)
    if day==nil
      ug_order  = "user_id ASC , start_at DESC , job_order ASC"
      ug_cond   = "user_id = #{u_id} and job_order=0"
      user_group = System::UsersGroupHistory.where(ug_cond).order(ug_order)
      group = System::GroupHistory.find(user_group[0].group_id) unless user_group.blank?
      return group.id
    else
      ug_order  = "user_id ASC , start_at DESC , job_order ASC"
      ug_cond   = "user_id = #{u_id} and job_order=0 and start_at < #{day}"
      user_group = System::UsersGroupHistory.where(ug_cond).order(ug_order)
      return nil if user_group.blank?
      user_group.each do |g|
        return g.id if System::GroupHistory.usable?(g.id , nil)==true
      end
      return nil
    end
  end

  def self.get_groups(user = Core.user)
    g_cond = "user_id=#{user.id}"
    g_order= "user_id ASC,start_at DESC"
    u_groups = System::UsersGroupHistory.where(g_cond).order(g_order)
    return nil if u_groups.blank?
    groups = []
    u_groups.each do |ug|
      groups << System::GroupHistory.find(ug.group_id)
    end
    return groups
  end

  def self.select_dd_group(day=nil,level=nil,parent_id=nil,all=nil)
    day   = Time.now     if day==nil
    dd_lists = []
    dd_lists << ['すべて',0] if all == 'all'
    if parent_id ==nil
      if level==nil
        dd_lists = System::GroupHistory.self.select_dd_tree(all)
      else
      end
    else
      g_order="code ASC , start_at DESC"
      g_cond="parent_id='#{parent_id}' and state = 'enabled'"
      groups = System::GroupHistory.where(g_cond).order(g_order)
      groups.each do |g|
        next if System::GroupHistory.usable?(g.id , "#{day}" )==false
        dd_lists << ['('+g.code+')'+g.name,g.id]
      end unless groups.blank?
    end
  end

  def self.select_dd_tree(all=nil)
    dd_lists = []
    dd_lists << ['すべて',0] if all == 'all'
    roots = System::GroupHistory.where("level_no=1 and state='enabled'")
    roots.each do |r|
      dd_lists << [r.name+'('+r.code+')',r.id]
      dd_lists = System::GroupHistory.get_childs(dd_lists,r)
    end
    return dd_lists
  end

  def self.get_childs(dd_lists,parent)
    c_lists = dd_lists
    childs = System::GroupHistory.where("state='enabled' and parent_id=#{parent.id}")
    return c_lists if childs.blank?
    pad_str = "　"*(parent.level_no.to_i-1)*2+"+"+"-"*(parent.level_no.to_i)*2
    childs.each do |c|
      c_lists << [pad_str+c.name+'('+c.code+')',c.id]
      c_lists = System::GroupHistory.get_childs(c_lists,c)
    end
    return c_lists
  end

  def self.get_group_tree(_group_id)
    _groups = []

    if _group_id.blank?
        _dept_conditions =  "state = 'enabled'"
        _dept_conditions << " and level_no = 2"
        _dept_conditions << " and parent_id = 1"
        _dep_order = "code ASC"
        _departments = System::GroupHistory.where(_dept_conditions).order(_dep_order)

        _departments.each do | _dep |
        _groups << _dep
            _sec_conditions =  "state = 'enabled'"
            _sec_conditions << " and level_no = 3"
            _sec_conditions << " and parent_id = #{_dep.id}"
            _sec_order = "code ASC"
            _sections = System::GroupHistory.where(_sec_conditions).order(_sec_order)

            _sections.each do | _sec |
                _groups << _sec
            end
        end
    else
        _dep = System::GroupHistory.find(_group_id)
        _groups << _dep
        if _dep.level_no == 2
            _sec_conditions =  "state = 'enabled'"
            _sec_conditions << " and level_no = 3"
            _sec_conditions << " and parent_id = #{_dep.id}"
            _sec_order = "code ASC"
            _sections = System::GroupHistory.where(_sec_conditions).order(_sec_order)

            _sections.each do | _sec |
                _groups << _sec
            end
        end
    end
    return _groups
  end

  def self.ldap_show(ldap)
    I18n.t('enum.system/group.ldap')[ldap.to_i]
  end
end
