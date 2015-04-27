class Gw::Admin::Piece::TabsController < ApplicationController
  include System::Controller::Scaffold
  layout false

  def index
    @piece_param = params['piece_param']

    @items = Gw::EditTab.where(level_no: 2, published: 'opened').order(sort_no: :asc)
  end
end
