# encoding: utf-8
class System::Recognizer < ActiveRecord::Base
  include System::Model::Base

  belongs_to :user, :foreign_key => :user_id, :class_name => 'System::User'

  def recognizable?(user)
    return false unless user.id == user_id
    return recognized_at.nil?
  end

  def recognize(user)
    return false unless user.id == user_id
    return false unless recognized_at.nil?
    self.recognized_at = Core.now
    save
  end

  def recognized?
    return false unless user_id
    return false unless recognized_at
    return true
  end
end
