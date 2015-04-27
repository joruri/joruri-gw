class Gw::Admin::Reminders::RequestsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  def index
    respond_to do |format|
      format.html { render :layout => false, :status => 200 }
    end
  end

end
