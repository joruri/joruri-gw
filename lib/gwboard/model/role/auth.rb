module Gwboard::Model::Role::Auth
  extend ActiveSupport::Concern

  included do
    scope :with_user_or_groups, ->(user = Core.user, role_code) {
      gcodes = ['0'] + user.groups.map{|g| g.self_and_ancestors.map(&:code)}.flatten
      where(role_code: role_code.split('/')).where([
        [arel_table[:user_id].eq(nil), arel_table[:group_code].in(gcodes)].reduce(:and),
        [arel_table[:user_id].not_eq(nil), arel_table[:user_code].eq(user.code)].reduce(:and)
      ].reduce(:or))
    }
  end

  def admin_role?
    role_code == 'a'
  end

  def write_role?
    role_code == 'w'
  end

  def read_role?
    role_code == 'r'
  end

  def group_role?
    user_id.blank?
  end

  def user_role?
    !group_role?
  end
end
