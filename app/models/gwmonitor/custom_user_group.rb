class Gwmonitor::CustomUserGroup < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :name
  after_validation :check_readers

  def check_readers
    if self.readers_json.blank?
      errors.add :readers_json, "配信先を設定してください。"
    else
      objects = JSON.parse(self.readers_json)
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
    Gwmonitor::CustomUserGroup.where(:state => 'enabled', :owner_uid => Core.user.id).order('sort_no,id').each do |dep|
      list << [dep.name, dep.id]
    end
    list = [["カスタム配信先を事前に登録してください",""]] if list == []
    return list
  end

  def self.first_group_id
    item = Gwmonitor::CustomUserGroup.where(:state => 'enabled', :owner_uid => Core.user.id).order('sort_no,id').first
    ret = 0
    ret = item.id unless item.blank?
    return ret
  end

  def self.get_user_select(gid)
    item = Gwmonitor::CustomUserGroup.where(:id => gid).first
    selects = []
    return selects if item.blank?
    return selects if item.readers_json.blank?

    users = JSON.parse(item.readers_json)
    users.each do |user|
      selects << [user[2].to_s,user[1].to_s]
    end
    return selects
  end

  def self.get_user_select_ajax(gid)
    item = Gwmonitor::CustomUserGroup.where(:id => gid).first
    selects = []
    return selects if item.blank?
    return selects if item.readers_json.blank?

    users = JSON.parse(item.readers_json)
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
