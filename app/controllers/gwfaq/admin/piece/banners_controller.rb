class Gwfaq::Admin::Piece::BannersController < ApplicationController
  layout false

  def index
    @title = Gwfaq::Control.find(params[:title_id])
  end
end
