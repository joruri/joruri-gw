class Digitallibrary::Admin::Piece::BannersController < ApplicationController
  layout false

  def index
    @title = Digitallibrary::Control.find(params[:title_id])
  end
end
