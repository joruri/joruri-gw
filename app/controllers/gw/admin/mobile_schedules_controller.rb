class Gw::Admin::MobileSchedulesController < Gw::Admin::SchedulesController
  include Gw::Controller::Mobile::Participant
  layout "admin/template/schedule"

  def ind_list
    @customs = System::CustomGroup.get_my_view
  end

  def list
    if params[:group_id].blank? or params[:group_id].to_i == 0
      @group_id = Core.user_group.id
      @group = Core.user_group
    else
      @group_id = params[:group_id].to_i
      @group = System::Group.where(id: params[:group_id]).first
    end
    @items = System::User.get_user_select(@group_id, nil)
    @groups = System::Group.where(parent_id: @group.id, state: "enabled").order(sort_no: :asc)
  end

  def confirm
    @line_box = 1
    if !params[:m].blank? && (params[:m] == "new" || params[:m] == "edit")
      item = Gw::Schedule.find(params[:id])
      @items = Gw::Schedule.where(schedule_parent_id: item.schedule_parent_id)
    else
      @items = Gw::Schedule.where(id: params[:id])
    end

    @items.each do |item|
      @auth_level = item.get_edit_delete_level(is_gw_admin: @is_gw_admin)
    end
  end

  def delete
    @item = Gw::Schedule.find(params[:id])
    auth_level = @item.get_edit_delete_level(auth = {:is_gw_admin => @is_gw_admin})
    return error_auth if auth_level[:delete_level] != 1

    redirect_url = "/gw/schedules/"
    redirect_url += "?gid=#{params[:gid]}&cgid=#{params[:cgid]}&uid=#{params[:uid]}&dis=#{params[:dis]}"

    _destroy @item, success_redirect_uri: redirect_url
  end

  def delete_repeat
    item = Gw::Schedule.find(params[:id])
    auth_level = item.get_edit_delete_level(auth = {:is_gw_admin => @is_gw_admin})
    return error_auth if auth_level[:delete_level] != 1

    Gw::Schedule.transaction do
      Gw::Schedule.where(schedule_repeat_id: item.repeat.id).each(&:destroy)
    end

    redirect_url = "/gw/schedules/"
    redirect_url += "?gid=#{params[:gid]}&cgid=#{params[:cgid]}&uid=#{params[:uid]}&dis=#{params[:dis]}"

    flash_notice '繰り返し一括削除', true
    redirect_to redirect_url
  end
end
