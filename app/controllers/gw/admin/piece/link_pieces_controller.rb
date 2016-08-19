class Gw::Admin::Piece::LinkPiecesController < ApplicationController
  include System::Controller::Scaffold
  layout false

  def index
    @piece_param = params['piece_param']
    @portal_mode = Gw::Property::PortalMode.first_or_new

    @items = Gw::EditLinkPiece.where(tab_keys: 10, level_no: 2, published: 'opened', state: 'enabled')
      .order(sort_no: :asc, id: :asc)
  end
end
