class Gwboard::Admin::Piece::PortalsController < ApplicationController
  layout false

  def index
    @portal_mode = Gw::Property::PortalMode.first_or_new
    @portal_disaster_bbs = Gw::Property::PortalDisasterBbs.first_or_new

    ids = [1]
    ids << @portal_disaster_bbs.options.to_i if @portal_mode.disaster_mode?
    ids += Gwboard::Property::PortalBbsLink.bbs_links
    @items = Gwbbs::Control.where(id: ids, state: 'public').select(&:is_readable?)
  end
end
