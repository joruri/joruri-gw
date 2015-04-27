class Gwbbs::Admin::Piece::UtilityBannersController < ApplicationController

  def index
    @title = nil
    @title = Gwbbs::Control.where(:id => params[:tid]).first unless params[:tid].blank?
    @new_url = "#{Core.current_node.public_uri}new"
  end
end