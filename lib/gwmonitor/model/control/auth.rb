module Gwmonitor::Model::Control::Auth
  extend ActiveSupport::Concern

  def is_sysadm?(user = Core.user)
    return @is_sysadm if defined? @is_sysadm
    @is_sysadm = self.class.is_sysadm?
  end

  def is_admin?(user = Core.user)
    return @is_admin if defined? @is_admin
    return @is_admin = is_sysadm?(user) || is_creator_user?(user) || is_creator_group?(user)
  end

  def is_creator_user?(user = Core.user)
    admin_setting == 1 && section_code == user.groups[0].code
  end

  def is_creator_group?(user = Core.user)
    admin_setting == 0 && creater_id == user.code
  end

  module ClassMethods
    def is_sysadm?(user = Core.user)
      user.has_role?("_admin/admin", "gwmonitor/admin")
    end
  end
end
