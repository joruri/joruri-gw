# encoding: utf-8
class Gw::Admin::Piece::LinkPiecesController < ApplicationController
  include System::Controller::Scaffold
  layout 'base'
  
  def index
    @piece_param = params['piece_param']
    @portal_mode = Gw::AdminMode.portal_mode

    @items = Gw::EditLinkPiece.where(:id => @piece_param, :published => 'opened', :state => 'enabled').order("state DESC, sort_no")
      .includes([:css, :icon, 
        :opened_children => [:css, :icon, :parent, 
          :opened_children => [:css, :icon, :parent]]])
  end
end
