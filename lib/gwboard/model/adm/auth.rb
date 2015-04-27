module Gwboard::Model::Adm::Auth
  extend ActiveSupport::Concern

  included do
    scope :with_user_or_groups, ->(user = Core.user) {
      gcodes = user.groups.map{|g| g.self_and_ancestors.map(&:code)}.flatten
      where([
        [arel_table[:user_id].eq(0), arel_table[:group_code].in(gcodes)].reduce(:and),
        [arel_table[:user_id].not_eq(0), arel_table[:user_code].eq(user.code)].reduce(:and) 
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
