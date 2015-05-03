class System::PrivName < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content

  has_many :role_name_privs, :class_name => 'System::RoleNamePriv', :foreign_key => :role_id
  has_many :role_names, :through => :role_name_privs, :source => :role, :class_name => 'System::RoleName'

  validates :display_name, presence: true, uniqueness: true
  validates :priv_name, presence: true, uniqueness: true, format: { with: /\A[^\/]+\z/, message: "'/'は使用できません。" }
  validates :sort_no, presence: true, numericality: true

  def state_no
    [['公開', 'public'], ['非公開', 'closed']]
  end

  def state_label
    state_no.rassoc(state).try(:first)
  end

  def editable?
    return true
  end

  def deletable?
    return false if System::Role.where(priv_user_id: self.id).exists?
    return false if System::RoleNamePriv.where(priv_id: self.id).exists?
    return true
  end
end
