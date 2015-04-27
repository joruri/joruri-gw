class Gwqa::Admin::Piece::BannersController < ApplicationController
  layout false

  def index
    @title = Gwqa::Control.find(params[:title_id])
  end
end
