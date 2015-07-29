# encoding: utf-8
class Pref::Gw::SystemUser < ActiveRecord::Base
  establish_connection :dev_jgw_core rescue nil
  
  validates_length_of :mobile_password, :minimum => 4, :if => Proc.new{|u| u.mobile_password && u.mobile_password.length != 0}

  def self.get_user(account, password)
    cond = Condition.new
    cond.and :code, account
    #cond.and :password, password
    find(:first, :conditions => cond.where)
  end
end