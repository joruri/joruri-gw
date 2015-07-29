# encoding: utf-8
class System::PrivName < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config

  validates_presence_of :display_name, :priv_name, :sort_no
  validates_uniqueness_of :priv_name, :display_name
  validates_numericality_of :sort_no


  def state_no
    [['公開', 'public'], ['非公開', 'closed']]
  end

  def state_label
    state_no.each {|a| return a[0] if a[1] == state }
    return nil
  end

  def editable?
    return true
  end
  def deletable?
    return false if System::Role.find_by_priv_user_id(id)
    return false if System::RoleNamePriv.find_by_priv_id(id)
    return true
  end

end
