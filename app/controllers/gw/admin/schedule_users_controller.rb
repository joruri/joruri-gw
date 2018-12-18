class Gw::Admin::ScheduleUsersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  def pre_dispatch
    #
  end

  def index
    raise Gw::SystemError, '不正な呼び出しです'
  end

  def show
    raise Gw::SystemError, '不正な呼び出しです'
  end

  def new
    raise Gw::SystemError, '不正な呼び出しです'
  end

  def create
    raise Gw::SystemError, '不正な呼び出しです'
  end

  def edit
    raise Gw::SystemError, '不正な呼び出しです'
  end

  def update
    raise Gw::SystemError, "不正な呼び出しです"
  end

  def getajax
    genre = params['s_genre']
    u = Core.user
    g = u.groups[0]
    case genre
    when nil
      nil
    when '_belong'
      cond = "state='enabled' and system_users_groups.group_id = #{g.id}"
      @item = System::User.new.find(:all, :conditions=>cond, :order=>'sort_no, code',
        :joins=>'left join system_users_groups on system_users.id = system_users_groups.user_id').collect{|x| [1, x.id, Gw.trim(x.display_name)]}
    when 'login'
      @item = System::User.new.find(:all, :conditions=>"id=#{u.id}").collect{|x| [1, x.id, Gw.trim(x.display_name)]}
    when 'login_group'
      @item = System::Group.new.find(:all, :conditions=>"id=#{g.id}").collect{|x| [2, x.id, Gw.trim(x.name)]}
    when /^group_(\d+)$/
      cond = "state='enabled' and system_users_groups.group_id = #{$1}"
      @item = System::User.new.find(:all, :conditions=>cond, :order=>'sort_no, code',
        :joins=>'left join system_users_groups on system_users.id = system_users_groups.user_id').collect{|x| [1, x.id, Gw.trim(x.display_name)]}
    when /^custom_group_(\d+)$/
      @item = []
      System::CustomGroup.find( "#{$1}" ).user_custom_group.sort{|a,b| a.sort_no <=> b.sort_no }.collect{|x|
        @item.push [1, x.user.id, Gw.trim( x.user.display_name )] if !x.user.blank? && x.user.code != AppConfig.gw.schedule_pref_admin['pref_admin_code'] && x.user.state == 'enabled'
       }
    when /^child_group_(\d+)$/
      group = System::Group.find($1)
      @item = group.enabled_users_for_options(ldap: 1).map {|user| [1, user.id, user.display_name] }
    else
      raise Gw::SystemError, '不正な呼び出しです'
    end
    respond_to do |format|
      format.json { render :json => @item }
    end
  end

  def getajax_restricted
    genre = params['s_genre']
    u = Core.user
    g = u.groups[0]
    @item = []
    if genre!='other' || params['type_id'].blank?
    else
      @prop_type = Gw::PropType.where(:id => params['type_id']).first
      @item = @prop_type.schedule_get_user_select(params) unless @prop_type.blank?
    end
    _show @item
  end

  def user_fields
    users = System::User.get_user_select(params[:g_id])
    render text: view_context.options_for_select(users), layout: false
  end

  def group_fields
    p_id = params[:p_id].to_s
    current_time = Time.now
    group_cond    = "state ='enabled'"
    group_cond    << " and start_at <= '#{current_time.strftime("%Y-%m-%d 00:00:00")}'"
    group_cond    << " and (end_at IS Null or end_at = '0000-00-00 00:00:00' or end_at > '#{current_time.strftime("%Y-%m-%d 23:59:59")}' ) "
    cond = "#{group_cond} and system_groups.parent_id = #{p_id}"
    groups = System::Group.where(cond).order(:level_no, :code).select(:id, :name)
    render text: view_context.options_from_collection_for_select(groups, :id, :name), layout: false
  end
end
