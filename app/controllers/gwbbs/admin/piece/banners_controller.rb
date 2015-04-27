class Gwbbs::Admin::Piece::BannersController < ApplicationController
  layout false

  def index
    @title = Gwbbs::Control.find(params[:title_id])
  end
end
