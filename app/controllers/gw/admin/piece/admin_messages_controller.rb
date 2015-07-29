# encoding: utf-8
class Gw::Admin::Piece::AdminMessagesController < ApplicationController
  include System::Controller::Scaffold
  layout 'base'
  
  def initialize_scaffold

  end
  
  def index
    @portal_mode = Gw::AdminMode.portal_mode

    @items = Gw::AdminMessage.where(:state => 1, :mode => @portal_mode.options == '3' ? [1,3] : [1,2])
      .order('state ASC, sort_no ASC, updated_at DESC').all
  end
end
