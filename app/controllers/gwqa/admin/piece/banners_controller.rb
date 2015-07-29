class Gwqa::Admin::Piece::BannersController < ApplicationController
  include Gwboard::Controller::Authorize
  include Gwqa::Model::DbnameAlias

  def index
    skip_layout
    @title = Gwqa::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title

    get_role_new unless params[:piece_param].blank?
  end
end
