# encoding: utf-8
class System::Admin::GroupsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def initialize_scaffold
		@current_no = 2
    @action = params[:action]
    if params[:parent].blank? || params[:parent] == '0'
      parent_id = 1
    else
      parent_id = params[:parent]
    end
    @parent = System::Group.find_by_id(parent_id)
    return http_error(404) if @parent.blank?
    Page.title = "ユーザー・グループ管理"
    @role_admin      = System::User.is_admin?
    return authentication_error(403) unless @role_admin == true
  end
  
  def list
    return authentication_error(403) unless @role_admin == true 
    Page.title = "ユーザー・グループ 全一覧画面"

    @groups = System::Group.get_level2_groups
  end

  def index
    params[:state] = params[:state].presence || 'enabled'
    
    item = System::Group.new
    item.and :parent_id, @parent.id
    item.and :ldap, params[:ldap] if params[:ldap] && params[:ldap] != 'all'
    item.and :state, params[:state] if params[:state] && params[:state] != 'all'
    item.page  params[:page], params[:limit]
    order = "state DESC,sort_no,code"
    @items = item.find(:all, :order=>order)
    
    _index @items
  end

  def show
    @item = System::Group.new.find(params[:id])
    _show @item
  end

  def new
    @item = System::Group.new({
        :parent_id    =>  @parent.id,
        :state        =>  'enabled',
        :level_no     =>  @parent.level_no.to_i + 1,
        :version_id   =>  @parent.version_id.to_i,
        :start_at     =>  Time.now.strftime("%Y-%m-%d 00:00:00"),
        :sort_no      =>  @parent.sort_no.to_i ,
        :ldap_version =>  nil,
        :ldap         =>  0
    })
  end
  def create
    @item = System::Group.new(params[:item])
    @item.parent_id     = @parent.id
    @item.level_no      = @parent.level_no.to_i + 1
    @item.version_id    = @parent.version_id.to_i
    @item.ldap_version  = nil
    @item.ldap          = 0
    _create @item
  end

  def update
    @item = System::Group.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = System::Group.new.find(params[:id])
    # 所属するユーザーが存在する場合は不可
    ug_cond="group_id=#{@item.id}"
    user_count = System::UsersGroup.count(:all,:conditions=>ug_cond)
    # 下位に有効な所属が存在する場合は不可
    g_cond="state='enabled' and parent_id=#{@item.id}"
    group_count = System::Group.count(:all,:conditions=>g_cond)

    if user_count == 0 and group_count == 0
      @item.state  = 'disabled'
      @item.end_at = Time.now.strftime("%Y-%m-%d 00:00:00")
      _update @item,{:success_redirect_uri=>url_for(:action=>'show'),:notice=>'無効にしました。'}
    else
      flash[:notice] = flash[:notice]||'ユーザーが所属しているか、下位に有効な所属があるときは、無効にできません。'
      redirect_to :action=>'show'
    end
  end
  
  def item_to_xml(item, options = {})
    options[:include] = [:status]
    xml = ''; xml << item.to_xml(options) do |n|
    end
    return xml
  end

  def list
    return authentication_error(403) unless @role_admin == true
    Page.title = "ユーザー・グループ 全一覧画面"

    @groups = System::Group.get_level2_groups
  end
  
end
