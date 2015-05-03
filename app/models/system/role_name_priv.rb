class System::RoleNamePriv < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :role, :class_name => 'System::RoleName'
  belongs_to :priv, :class_name => 'System::PrivName'

  validates :role_id, uniqueness: { scope: [:priv_id], message: 'と対象権限が登録済みのものと重複しています。' }

  def editable?
    return true
  end

  def deletable?
    !System::Role.where(role_name_id: self.role_id, priv_user_id: self.priv_id).exists?
  end
end
