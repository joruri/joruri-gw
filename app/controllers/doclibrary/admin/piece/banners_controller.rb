class Doclibrary::Admin::Piece::BannersController < ApplicationController
  include Gwboard::Controller::Authorize
  include Doclibrary::Model::DbnameAlias

  def index
    skip_layout
    @title = Doclibrary::Control.find_by_id(params[:title_id])
    return http_error(404) unless @title

    unless params[:piece_param].blank?
      admin_flags(params[:title_id])
      get_writable_flag
    end
  end
end
