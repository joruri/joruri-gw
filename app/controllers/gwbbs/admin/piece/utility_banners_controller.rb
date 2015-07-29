class Gwbbs::Admin::Piece::UtilityBannersController < ApplicationController

  def index
    @title = nil
    @title = Gwbbs::Control.find_by_id(params[:tid]) unless params[:tid].blank?
    @new_url = "#{Core.current_node.public_uri}new"
  end
end