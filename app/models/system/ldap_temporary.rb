# encoding: utf-8
class System::LdapTemporary < ActiveRecord::Base
  include System::Model::Base

  def synchro_target?
    return true
  end

  def children
    tmp = self.class.new
    tmp.and :version, version
    tmp.and :parent_id, id
    tmp.and :data_type, 'group'
    return tmp.find(:all,:order=>"code")
  end

  def users
    tmp = self.class.new
    tmp.and :version, version
    tmp.and :parent_id, id
    tmp.and :data_type, 'user'
    return tmp.find(:all,:order=>"code")
  end
end
