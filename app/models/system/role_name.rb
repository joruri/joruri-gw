class System::RoleName < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :display_name, :table_name, :sort_no
  validates_uniqueness_of :table_name, :display_name
  validates_numericality_of :sort_no
  validates :table_name, format: { with: /\A[^\/]+\z/, message: "'/'は使用できません。" }

  def editable?
    return true
  end

  def deletable?
    return false if System::Role.where(:role_name_id => id).first
    return false if System::RoleNamePriv.where(:role_id => id).first
    return true
  end
end
