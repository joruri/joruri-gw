module Gwcircular::Model::Doc::Auth

  def is_editable?(user = Core.user)
    return @is_editable if defined? @is_editable
    @is_editable = control.is_admin? || (control.is_writable?(user) && target_user_code == user.code)
  end
end
