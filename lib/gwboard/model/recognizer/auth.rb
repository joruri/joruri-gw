module Gwboard::Model::Recognizer::Auth
  extend ActiveSupport::Concern

  included do
    scope :with_user, ->(user = Core.user) {
      where(arel_table[:code].eq(user.code))
    }
  end

  def recognized?
    recognized_at.present?
  end
end
