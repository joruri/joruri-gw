#encoding:utf-8
class Gw::Admin::PrefExecutivesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/pref"

  def initialize_scaffold
    Page.title = "全庁幹部在庁表示"
    @public_uri = '/gw/pref_executives'
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    init_params
		@items1 = Gw::PrefExecutive.get_members(:u_lname => FALSE).order(@sort_keys)
		@items2 = Gw::PrefExecutive.get_members(:u_lname => TRUE).order(@sort_keys)
  end

  def state_change
		@item = Gw::PrefExecutive.state_change(params[:id])
    return redirect_to(@public_uri)
  end


  def init_params
    @role_developer  = Gw::PrefExecutive.is_dev?
    @role_admin      = Gw::PrefExecutive.is_admin?
    @u_role = @role_developer || @role_admin

    @sort_keys = nz(params[:sort_keys], 'u_order')
    @css = %w(/_common/themes/gw/css/schedule.css)

    @sp_mode = :zaichou

    @users = Gw::Model::Schedule.get_users(params)
    @user   = @users[0]
    @uid    = @user.id if !@user.blank?
    @uid = nz(params[:uid], Site.user.id) if @uid.blank?
    @myuid = Site.user.id
    @gid = nz(params[:gid], @user.groups[0].id) rescue Site.user_group.id
    @mygid = Site.user_group.id

    if params[:cgid].blank? && @gid != 'me'
      x = System::CustomGroup.get_my_view( {:is_default=>1,:first=>1})
      if !x.blank?
        @cgid = x.id
      end
    else
      @cgid = params[:cgid]
    end

    @first_custom_group = System::CustomGroup.get_my_view( {:sort_prefix => Site.user.code,:first=>1})

    @ucode = Site.user.code
    @gcode = Site.user_group.code

    @state_user_or_group = params[:cgid].blank? ? ( params[:gid].blank? ? :user : :group ) : :custom_group

    @group_selected = ( params[:cgid].blank? ? '' : 'custom_group_'+params[:cgid] )

    a_qs = []
    a_qs.push "uid=#{params[:uid]}" unless params[:uid].nil?
    a_qs.push "gid=#{params[:gid]}" unless params[:gid].nil? && !params[:cgid].nil?
    a_qs.push "cgid=#{params[:cgid]}" unless params[:cgid].nil? && !params[:gid].nil?
    a_qs.push "todo=#{params[:todo]}" unless params[:todo].nil?
    @schedule_move_qs = a_qs.join('&')

    @is_gw_admin = Gw.is_admin_admin?
    @is_pref_admin = Gw::Schedule.is_schedule_pref_admin?

    @is_kauser = @kucode == @ucode ? true : false

    unless params[:cgid].blank?
      @custom_group = System::CustomGroup.find(:first, :conditions=>["id= ? ", params[:cgid]])
      if !@custom_group.blank?
        Page.title = @custom_group.name
      end
    end

    @up_schedules = nz(Gw::Model::UserProperty.get('schedules'.singularize), {})

    @schedule_settings = Gw::Model::Schedule.get_settings 'schedules', {}

  end
end
