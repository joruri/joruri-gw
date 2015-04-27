class System::PrivName < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :display_name, :priv_name, :sort_no
  validates_uniqueness_of :priv_name, :display_name
  validates_numericality_of :sort_no
  validates :priv_name, format: { with: /\A[^\/]+\z/, message: "'/'は使用できません。" }

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
    return false if System::Role.where(:priv_user_id => id).first
    return false if System::RoleNamePriv.where(:priv_id => id).first
    return true
  end
end
