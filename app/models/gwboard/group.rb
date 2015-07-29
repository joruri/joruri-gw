# -*- encoding: utf-8 -*-
class Gwboard::Group < System::Group

  acts_as_tree :order=>'sort_no'

  def self.level
    list = []
    System::Group.new.find(:all, :conditions => {:state => 'enabled', :level_no => 2}, :order => :code).each do |dep|
      list << ['+' + dep.code + dep.name, 0]
      System::Group.find(:all, :conditions => {:state => 'enabled', :parent_id => dep.id}, :order => :code).each do |sec|
        list << ['+-' + sec.code + sec.name, sec.id]
      end
    end
    return list
  end

  def self.level2
    list = [["制限なし", 0]]
    System::Group.new.find(:all, :conditions => {:state => 'enabled',:level_no => 2}, :order => :code).each do |dep|
      list << [dep.name, dep.id]
    end
    return list
  end

  def self.level2_top_blank
    list = []
    System::Group.new.find(:all, :conditions => {:state => 'enabled',:level_no => 2}, :order => :code).each do |dep|
      list << [dep.name, dep.id]
    end
    return list
  end

  def self.level3(p_id)
    list = []
    if p_id == 0
      list = [["制限なし", 0]]
    else
      System::Group.new.find(:all, :conditions => {:state => 'enabled', :id => p_id}, :order => :code).each do |dep|
        list << [dep.name, dep.id]
      end
      System::Group.new.find(:all, :conditions => {:state => 'enabled', :parent_id => p_id, :level_no => 3}, :order => :code).each do |dep|
        list << [dep.name, dep.id]
      end
    end
    return list
  end

  def self.level3_all(options=nil)
    current_time = Time.now
    group_cond    = "state='enabled' and level_no=3 "

#    if options.blank?
#      group_cond    << " and ldap=1"
#    else
#      if(options[:ldap] and options[:ldap].to_i=1)
#      else
#        group_cond    << " and ldap=1"
#      end
#    end

    group_cond    << " and start_at <= '#{current_time.strftime("%Y-%m-%d 00:00:00")}'"
    group_cond    << " and (end_at IS Null or end_at = '0000-00-00 00:00:00' or end_at > '#{current_time.strftime("%Y-%m-%d 23:59:59")}' ) "
    return System::Group.new.find(:all, :conditions => group_cond, :order => 'sort_no, code')
  end

  def self.level3_all_hash(options=nil)
    current_time = Time.now
    group_cond    = "state='enabled' and level_no=3 "

#    if options.blank?
#      group_cond    << " and ldap=1"
#    else
#      if(options[:ldap] and options[:ldap].to_i=1)
#      else
#        group_cond    << " and ldap=1"
#      end
#    end

    group_cond    << " and start_at <= '#{current_time.strftime("%Y-%m-%d 00:00:00")}'"
    group_cond    << " and (end_at IS Null or end_at = '0000-00-00 00:00:00' or end_at > '#{current_time.strftime("%Y-%m-%d 23:59:59")}' ) "
    return System::Group.new.find(:all, :conditions => group_cond, :select=> 'code, name', :order => 'sort_no, code').index_by(&:code)
  end

  def self.level2_only
    list = []
    System::Group.new.find(:all, :conditions => {:state => 'enabled', :level_no => 2}, :order => :code).each do |dep|
      list << [dep.name, dep.id]
    end
    return list
  end

  def self.level3_only(p_id)
    list = []
    if p_id == 0
      System::Group.new.find(:all, :conditions => {:state => 'enabled', :level_no => 3}, :order => :code).each do |dep|
        list << [dep.name, dep.id]
      end
    else
      System::Group.new.find(:all, :conditions => {:state => 'enabled', :id => p_id}, :order => :code).each do |dep|
        list << [dep.name, dep.id]
      end
      System::Group.new.find(:all, :conditions => {:state => 'enabled', :parent_id => p_id, :level_no => 3}, :order => :code).each do |dep|
        list << [dep.name, dep.id]
      end
    end
    return list
  end

  def self.level2_caption_all
    list = [["全ての所属", 0]]
    System::Group.new.find(:all, :conditions => {:state => 'enabled',:level_no => 2}, :order => :code).each do |dep|
      list << [dep.name, dep.id]
    end
    return list
  end

  def self.level3_select(p_id=nil)
    list = []
    return list if p_id.blank?

    if p_id == 0
      list = [["全ての所属", 0]]
    else
      System::Group.new.find(:all, :conditions => {:state => 'enabled', :parent_id => p_id, :level_no => 3}, :order => :code).each do |dep|
        list << [dep.name, dep.id]
      end
    end
    return list
  end
end
