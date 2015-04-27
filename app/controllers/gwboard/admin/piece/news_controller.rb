class Gwboard::Admin::Piece::NewsController < ApplicationController
  layout false

  def index
    @portal_mode = Gw::Property::PortalMode.first_or_new
    @portal_disaster_bbs = Gw::Property::PortalDisasterBbs.first_or_new

    piece_parms = params[:piece_param].split(/_/)
    system = piece_parms[0]
    title_id = piece_parms[1].to_i

    @title = gwboard_news_control(system).where(state: 'public', id: title_id).first
    return render nothing: true if @title.blank? || !@title.is_readable?

    @limit_portal = request.mobile? ? 4 : 10

    @items = @title.docs.index_select(@title).public_docs
      .order(latest_updated_at: :desc, id: :asc)
      .paginate(page: 1, per_page: @limit_portal)
      .preload(:comments_only_id)
  end

  private

  def gwboard_news_control(system)
    "#{system.capitalize}::Control".constantize
  end
end
