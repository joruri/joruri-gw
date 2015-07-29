# encoding: utf-8
class System::Creator < ActiveRecord::Base
  include System::Model::Base

  belongs_to :user,  :foreign_key => :user_id,  :class_name => 'System::User'
  belongs_to :group, :foreign_key => :group_id, :class_name => 'System::Group'

  before_save :set_user
  before_save :set_group

  validates_presence_of :unid

  def set_user
    unless user_id
      self.user_id = Core.user ? Core.user.id : 0
    end
  end

  def set_group
    unless group_id
      self.group_id = Core.user_group ? Core.user_group.id : 0
    end
  end
end
