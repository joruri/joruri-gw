module Gwboard::Model::Doc::ReadFlag
  extend ActiveSupport::Concern


  included do
    scope :search_read_state, ->(state) {
      flag_class =
      case state
      when "read"
        rel = joins(:read_flags).where(Gwbbs::Flag.arel_table[:user_id].eq(Core.user.id))
      when "unread"
        rel = joins("LEFT JOIN #{Gwbbs::Flag.table_name} ON #{Gwbbs::Flag.table_name}.parent_id = #{Gwbbs::Doc.table_name}.id AND #{Gwbbs::Flag.table_name}.user_id = '#{Core.user.id}'")
        rel = rel.where(Share::NotificationState.arel_table[:rid].eq(nil))
      else
        rel = joins("LEFT JOIN #{Gwbbs::Flag.table_name} ON #{Gwbbs::Flag.table_name}.parent_id = #{Gwbbs::Doc.table_name}.id AND #{Gwbbs::Flag.table_name}.user_id = '#{Core.user.id}'")
      end
      rel
    }
  end

  def set_read_flag(user=Core.user)
    return if read_flags.where(user_id: user.id).first.present?
    read_flags.create({title_id: title_id, user_id: Core.user.id})
  end

  def remove_read_flag(user=Core.user)
    if user_state = read_flags.where(user_id: user.id).first
      user_state.destroy
    end
  end

  def read_flag_class(user=Core.user)
    return " read" if read_flags.where(user_id: user.id).present?
    return " unread"
  end

end
