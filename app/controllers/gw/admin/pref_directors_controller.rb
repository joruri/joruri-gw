class Gw::Admin::PrefDirectorsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/pref"

  def pre_dispatch
    Page.title = "部課長在庁表示"
    @public_uri = '/gw/pref_directors'
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    init_params

    @items = Gw::PrefDirector.where(is_governor_view: 1).order(@sort_keys)
    @item_links = Gw::PrefDirector.where(is_governor_view: 1).group(:parent_g_code).order(:parent_g_order)
  end

  def state_change
    @item = Gw::PrefDirector.where(uid: params[:id]).first
    @item.toggle_state

    location  = @public_uri
    location += "##{params[:locate]}" unless params[:locate].blank?
    return redirect_to(location)
  end

  def init_params
    @role_developer  = Gw::PrefDirector.is_dev?
    @role_admin      = Gw::PrefDirector.is_admin?
    @u_role = @role_developer || @role_admin

    @sort_keys = nz(params[:sort_keys], 'parent_g_order, u_order')
    @css = %w(/_common/themes/gw/css/schedule.css)

    @sp_mode = :zaichou

    @users = Gw::Model::Schedule.get_users(params)
    @user   = @users[0]
    @uid    = @user.id if !@user.blank?
    @uid = nz(params[:uid], Core.user.id) if @uid.blank?
    @myuid = Core.user.id
    @gid = nz(params[:gid], @user.groups[0].id) rescue Core.user_group.id
    @mygid = Core.user_group.id

    if params[:cgid].blank? && @gid != 'me'
      x = System::CustomGroup.get_my_view( {:is_default=>1,:first=>1})
      if !x.blank?
        @cgid = x.id
      end
    else
      @cgid = params[:cgid]
    end

    @first_custom_group = System::CustomGroup.get_my_view( {:sort_prefix => Core.user.code,:first=>1})

    @ucode = Core.user.code  # ユーザーコード
    @gcode = Core.user_group.code  # グループコード

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
      @custom_group = System::CustomGroup.where(id: params[:cgid]).first
      if !@custom_group.blank?
        Page.title = @custom_group.name
      end
    end

    @schedule_settings = Gw::Schedule.load_system_and_user_settings(Core.user)

  end

end
