module Concerns::Gw::Memo::Reminder
  extend ActiveSupport::Concern

  included do
    scope :memos_for_reminder, ->(user, property) {
      read = property.memos['read_memos_display'].to_i
      unread = property.memos['unread_memos_display'].to_i
      if read == 0 && unread == 0
        none
      elsif read == 0
        with_receiver(user).is_finished_memos_until(0, unread)
      elsif unread == 0
        with_receiver(user).is_finished_memos_until(1, read)
      else
        with_receiver(user).where([
          is_finished_memos_until(1, read).where_values.reduce(:and),
          is_finished_memos_until(0, unread).where_values.reduce(:and)
        ].reduce(:or))
      end
    }
    scope :is_finished_memos_until, ->(finished, display_date) {
      where(is_finished: finished).where(arel_table[:created_at].gt(Date.today - display_date + 1))
    }
  end
end
