class System::RoleName < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content

  has_many :role_name_privs, :class_name => 'System::RoleNamePriv', :foreign_key => :role_id
  has_many :priv_names, :through => :role_name_privs, :source => :priv, :class_name => 'System::PrivName'

  validates :display_name, presence: true, uniqueness: true
  validates :table_name, presence: true, uniqueness: true, format: { with: /\A[^\/]+\z/, message: "'/'は使用できません。" }
  validates :sort_no, presence: true, numericality: true

  def editable?
    return true
  end

  def deletable?
    return false if System::Role.where(role_name_id: self.id).exists?
    return false if System::RoleNamePriv.where(role_id: self.id).exists?
    return true
  end
end
