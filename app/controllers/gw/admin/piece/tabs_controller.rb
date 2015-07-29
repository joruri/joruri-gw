# encoding: utf-8
class Gw::Admin::Piece::TabsController < ApplicationController
  include System::Controller::Scaffold
  layout 'base'
  
  def index
    @piece_param = params['piece_param']
    
    cond  = " level_no=2 and published='opened' "
    order = " sort_no "
    @items = Gw::EditTab.find(:all, :conditions => cond, :order => order)
  end
end
