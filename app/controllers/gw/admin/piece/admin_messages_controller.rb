class Gw::Admin::Piece::AdminMessagesController < ApplicationController
  include System::Controller::Scaffold
  layout false
  
  def index
    @portal_mode = Gw::Property::PortalMode.first_or_new

    @items = Gw::AdminMessage.where(state: 1, mode: @portal_mode.disaster_mode? ? [1,3] : [1,2])
      .order(sort_no: :asc, updated_at: :desc).limit(2)
  end
end
