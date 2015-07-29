# encoding: utf-8
class Gw::Admin::Piece::PortalLeftAddsController < ApplicationController
  include System::Controller::Scaffold
  layout 'base'
  
  def initialize_scaffold

  end

  def index
    today = Time.now.strftime('%Y-%m-%d')
    item    = Gw::PortalAdd.new
    cond    = "published = 'opened' and publish_start_at <= '#{today}' and publish_end_at >= '#{today}' and place = 1"
    order   = "sort_no ASC"
    @items  = item.find(:all, :conditions => cond, :order => order, :limit => 3)
  end
end
