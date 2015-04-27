class Gwcircular::Admin::Piece::RecentController < ApplicationController
  include System::Controller::Scaffold
  layout false

  def index
    params[:title_id] = 1
    @title = Gwcircular::Control.find(params[:title_id])

    @items = @title.docs.commission_docs.abled_docs.where(state: 'unread').with_target_user(Core.user)
      .order(latest_updated_at: :desc, expiry_date: :desc).limit(3)
  end
end
