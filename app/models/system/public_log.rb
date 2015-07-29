# encoding: utf-8
class System::PublicLog < ActiveRecord::Base
  include System::Model::Base

  belongs_to :user,       :foreign_key => :user_id,   :class_name => 'System::User'
  belongs_to :unid_data,  :foreign_key => :item_unid, :class_name => 'System::Unid'

  def add(params)
    self.user_id    = params[:user_id]    if params[:user_id]
    self.controller = params[:controller] if params[:controller]
    self.action     = params[:action]     if params[:action]
    self.item_unid  = params[:item].unid  if params[:item] && defined?(params[:item].unid)
    return save
  end
end
