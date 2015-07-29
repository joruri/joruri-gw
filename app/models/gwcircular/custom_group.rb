# -*- encoding: utf-8 -*-
class Gwcircular::CustomGroup < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :name
  validates_numericality_of :sort_no, :greater_than_or_equal_to => 0
  
  after_validation :check_readers

  def check_readers
    if self.readers_json.blank?
      errors.add :readers_json, "配信先を設定してください。"
    else
      objects = JsonParser.new.parse(self.readers_json)
      if objects.count == 0
        errors.add :readers_json, "配信先を設定してください。"
      end
    end
  end

  def states
    {'enabled' => '有効', 'disabled' => '無効'}
  end

  def self.custom_select
    list = []
    Gwcircular::CustomGroup.new.find(:all, :conditions => {:state => 'enabled', :owner_uid => Site.user.id}, :order => 'sort_no,id').each do |dep|
      list << [dep.name, dep.id]
    end
    list = [["カスタム配信先を事前に登録してください",""]] if list == []
    return list
  end

  def self.first_group_id
    item = Gwcircular::CustomGroup.new.find(:first, :conditions => {:state => 'enabled', :owner_uid => Site.user.id}, :order => 'sort_no,id')
    ret = 0
    ret = item.id unless item.blank?
    return ret
  end

  def self.get_user_select(gid)
    item = Gwcircular::CustomGroup.find_by_id(gid)
    selects = []
    return selects if item.blank?
    return selects if item.readers_json.blank?

    users = JsonParser.new.parse(item.readers_json)
    users.each do |user|
      selects << [user[2].to_s,user[1].to_s]
    end
    return selects
  end

  def self.get_user_select_ajax(gid)
    item = Gwcircular::CustomGroup.find_by_id(gid)
    selects = []
    return selects if item.blank?
    return selects if item.readers_json.blank?

    users = JsonParser.new.parse(item.readers_json)
    users.each do |user|
      selects << [user[0].to_s,user[1].to_s,user[2].to_s]
    end
    return selects
  end

  def item_path
    return "#{Site.current_node.public_uri.chop}"
  end

  def update_path
    return "#{Site.current_node.public_uri}#{self.id}"
  end

end
