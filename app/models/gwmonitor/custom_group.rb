# -*- encoding: utf-8 -*-
class Gwmonitor::CustomGroup < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :name
  validates_numericality_of :sort_no, :greater_than_or_equal_to => 0
  
  after_validation :check_readers

  def check_readers
    if self.reader_groups_json.blank?
      errors.add :reader_groups_json, "を設定してください。"
    else
      objects = JsonParser.new.parse(self.reader_groups_json)
      if objects.count == 0
        errors.add :reader_groups_json, "を設定してください。"
      end
    end
  end

  def states
    {'enabled' => '有効', 'disabled' => '無効'}
  end

  def self.custom_select
    list = []
    Gwmonitor::CustomGroup.new.find(:all, :conditions => {:state => 'enabled', :owner_uid => Site.user.id}, :order => 'sort_no,id').each do |dep|
      list << [dep.name, dep.id]
    end
    list = [["カスタム配信先を事前に登録してください",""]] if list == []
    return list
  end

  def self.first_group_id
    item = Gwmonitor::CustomGroup.new.find(:first, :conditions => {:state => 'enabled', :owner_uid => Site.user.id}, :order => 'sort_no,id')
    ret = 0
    ret = item.id unless item.blank?
    return ret
  end

  def self.get_user_select(gid)
    item = Gwmonitor::CustomGroup.find_by_id(gid)
    selects = []
    return selects if item.blank?
    return selects if item.reader_groups_json.blank?

    users = JsonParser.new.parse(item.reader_groups_json)
    users.each do |user|
      selects << [user[2].to_s,user[1].to_s]
    end
    return selects
  end

  def self.get_user_select_ajax(gid)
    item = Gwmonitor::CustomGroup.find_by_id(gid)
    selects = []
    return selects if item.blank?
    return selects if item.reader_groups_json.blank?

    users = JsonParser.new.parse(item.reader_groups_json)
    users.each do |user|
      selects << [user[0].to_s,user[1].to_s,user[2].to_s]
    end
    return selects
  end

#  def item_path
#    return "/gwmonitor/custom_groups"
#  end
end
