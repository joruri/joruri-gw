module Gwboard::Model::FolderAcl::Auth
  extend ActiveSupport::Concern

  included do
    scope :with_user_or_groups, ->(user = Core.user) {
      where([
        arel_table[:acl_flag].eq(0),
        arel_table[:acl_flag].eq(1).and( arel_table[:acl_section_code].in(user.groups_and_ancestors_codes) ),
        arel_table[:acl_flag].eq(2).and( arel_table[:acl_user_code].eq(user.code) )
      ].reduce(:or))
    }
  end

  def all_acl?
    acl_flag == 0
  end

  def group_acl?
    acl_flag == 1
  end

  def user_acl?
    acl_flag == 2
  end
end
