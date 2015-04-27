class Doclibrary::Admin::Piece::BannersController < ApplicationController
  layout false

  def index
    @title = Doclibrary::Control.find(params[:title_id])
  end
end
