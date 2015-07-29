# encoding: utf-8
class System::RoleNamePriv < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Config

  belongs_to :role  ,:class_name=>'System::RoleName'
  belongs_to :priv  ,:class_name=>'System::PrivName'

  validates_uniqueness_of :role_id, :scope => [:priv_id],:message=>'と対象権限が登録済みのものと重複しています。'

  def self.get_priv_items(role_id)
    cond  = "role_id = #{role_id}"
    items = self.find(:all, :conditions=>cond,
      :joins=>[:priv], :order => 'system_priv_names.sort_no')
    return items
  end

  def self.get_priv_names(role_id)

    items = self.get_priv_items(role_id)

    ret = Array.new
    items.each do |item|
      ret << item.priv.display_name
    end
    return ret
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
    return false if System::Role.find(:first, :conditions => {:role_name_id => role_id, :priv_user_id => priv_id})
    return true
  end
end
