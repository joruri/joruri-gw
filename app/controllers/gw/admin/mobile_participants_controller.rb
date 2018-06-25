class Gw::Admin::MobileParticipantsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gw::Controller::Mobile::Participant

  layout "admin/template/memo"

  def pre_dispatch
    #
  end

  def index
    if params[:group_id].blank? or params[:group_id].to_i == 0
      @group_id = Core.user_group.id
      @group = Core.user_group
    else
      @group_id = params[:group_id].to_i
      @group = System::Group.where(:id => params[:group_id]).first
    end
    @items = System::User.get_user_select(@group_id,nil)
    @groups  = System::Group.where("parent_id = ? AND state = ?",@group.id,"enabled").order(:sort_no)
  end

end
