class Gwboard::Admin::Piece::PortalsController < ApplicationController

  def index
    @portal_mode = Gw::AdminMode.portal_mode
    @portal_disaster_bbs = Gw::AdminMode.portal_disaster_bbs

    ids = [1]
    ids << @portal_disaster_bbs.options.to_i if @portal_mode.options == '3'

    @items = ids.map{|id| Gwbbs::Control.where(:id => id, :state => 'public').first}.compact.select{|item| Gw::Tool::Board.readable_board?('gwbbs', item.id)}
  end
end
