class Gw::PrefConfig < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  before_create :set_creator
  before_update :set_updator

  def display_name_select
    [['通常表示', 'normal'],['管理者にのみ表示', 'admin']]
  end

  def self.names_label(name)
    display_name_select.each {|a| return a[0] if a[1] == name }
    return nil
  end

  def progress_state_select
    [['準備中', 'prepare'],['進行中', 'progress'],['完了', 'finish']]
  end

  def progress_state_label
    progress_state_select.each {|a| return a[0] if a[1] == options }
    return nil
  end

  def self.display_view(type)
    item = Gw::PrefConfig.where(:option_type => type, :name => "admin")
    if item.blank?
      "normal"
    else
      "admin"
    end
  end

private

  def set_creator
    self.created_at    = Time.now
    self.created_user  = Core.user.name if Core.user
    self.created_group = Core.user_group.id if Core.user_group
  end

  def set_updator
    self.updated_at    = Time.now
    self.updated_user  = Core.user.name if Core.user
    self.updated_group = Core.user_group.id if Core.user_group
  end
end
