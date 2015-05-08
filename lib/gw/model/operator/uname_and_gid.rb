module Gw::Model::Operator::UnameAndGid
  extend ActiveSupport::Concern

  included do
    before_create :set_creator
    before_update :set_updator
  end

  private

  def set_creator
    self.created_user = Core.user.name if Core.user
    self.created_group = Core.user_group.id if Core.user_group
  end

  def set_updator
    self.updated_user = Core.user.name if Core.user
    self.updated_group = Core.user_group.id if Core.user_group
  end
end
