module Gw::Model::Operator::Id
  extend ActiveSupport::Concern

  included do
    before_create :set_creator
    before_update :set_updator
  end

  private

  def set_creator
    self.created_uid = Core.user.id if Core.user
    self.created_gid = Core.user_group.id if Core.user_group
  end

  def set_updator
    self.updated_uid = Core.user.id if Core.user
    self.updated_gid = Core.user_group.id if Core.user_group
  end
end
