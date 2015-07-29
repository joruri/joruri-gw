# encoding: utf-8
class Sys::Admin::FrontController < Sys::Controller::Admin::Base
  def index
#    item = Sys::Message.new.public
#    @messages = item.find(:all, :order => 'published_at DESC')
    @messages = nil
    
#    item = Sys::Maintenance.new.public
#    @maintenances = item.find(:all, :order => 'published_at DESC')
    @maintenances = nil
    
    #@calendar = Util::Date::Calendar.new(nil, nil)
  end
end
