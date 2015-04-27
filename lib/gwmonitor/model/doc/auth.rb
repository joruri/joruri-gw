module Gwmonitor::Model::Doc::Auth
  extend ActiveSupport::Concern

  def is_commissioned?(user = Core.user)
    is_commissioned_group?(user) || is_commissioned_user?(user)
  end

  def is_commissioned_group?(user = Core.user)
    send_division == 1 && section_code == user.groups[0].code
  end

  def is_commissioned_user?(user = Core.user)
    send_division == 2 && user_code == user.code
  end
end
