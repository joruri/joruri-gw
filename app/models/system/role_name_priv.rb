class System::RoleNamePriv < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :role, :class_name => 'System::RoleName'
  belongs_to :priv, :class_name => 'System::PrivName'

  validates_uniqueness_of :role_id, :scope => [:priv_id], 
    :message => 'と対象権限が登録済みのものと重複しています。'

  def self.get_priv_items(role_id)
    self.joins(:priv).where(:role_id => role_id).order('system_priv_names.sort_no')
  end

  def self.get_priv_names(role_id)
    get_priv_items(role_id).map{|item| item.priv.display_name}
  end

  def self.params_set(params)
    ret = ""
    'role_id'.split(':').each do |col|
      unless params[col.to_sym].blank?
        ret += "&" unless ret.blank?
        ret += "#{col}=#{params[col.to_sym]}"
      end
    end
    ret = '?' + ret unless ret.blank?
    return ret
  end

  def editable?
    return true
  end

  def deletable?
    return false if System::Role.where(:role_name_id => role_id, :priv_user_id => priv_id).first
    return true
  end
end
