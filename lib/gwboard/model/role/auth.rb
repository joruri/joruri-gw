module Gwboard::Model::Role::Auth
  extend ActiveSupport::Concern

  included do
    scope :with_user_or_groups, ->(user = Core.user, role_code) {
      gcodes = ['0'] + user.groups_and_ancestors_codes
      where(role_code: role_code.split('/')).where([
        arel_table[:user_id].eq(nil).and( arel_table[:group_code].in(gcodes) ),
        arel_table[:user_id].not_eq(nil).and( arel_table[:user_code].eq(user.code) )
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
