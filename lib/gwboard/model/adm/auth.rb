module Gwboard::Model::Adm::Auth
  extend ActiveSupport::Concern

  included do
    scope :with_user_or_groups, ->(user = Core.user) {
      where([
        arel_table[:user_id].eq(0).and( arel_table[:group_code].in(user.groups_and_ancestors_codes) ),
        arel_table[:user_id].not_eq(0).and( arel_table[:user_code].eq(user.code) )
      ].reduce(:or))
    }
  end

  def group_adm?
    user_id == 0
  end

  def user_adm?
    !group_adm?
  end
end
