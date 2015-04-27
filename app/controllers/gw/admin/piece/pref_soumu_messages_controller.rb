class Gw::Admin::Piece::PrefSoumuMessagesController < ApplicationController
  include System::Controller::Scaffold
  layout false

  def index
    @items = Gw::PrefSoumuMessage.where(state: 1, tab_keys: params[:piece_param])
      .order(sort_no: :asc, updated_at: :desc).limit(2)
  end
end
