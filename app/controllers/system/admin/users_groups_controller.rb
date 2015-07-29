# encoding: utf-8
class System::Admin::UsersGroupsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def initialize_scaffold
		@current_no = 2
    id      = params[:parent] == '0' ? 1 : params[:parent]
    @parent = System::Group.find_by_id(id)
    return http_error(404) if @parent.blank?
    params[:limit] = Gw.nz(params[:limit],30)
    Page.title = "ユーザー・グループ管理"
    @role_admin      = System::User.is_admin?
    return authentication_error(403) unless @role_admin == true
  end

  def index
    item = System::UsersGroup.new
    item.group_id = @parent.id
    item.page  params[:page], params[:limit]
    item.order params[:sort], "user_code ASC"
    @items = item.find(:all)

    _index @items
  end

  def show
    @item = System::UsersGroup.new.find(params[:id])
    _show @item
  end

  def new
    @item = System::UsersGroup.new({
      :group_id  => @parent.id,
      :job_order => 0,
      :start_at  => Time.now 
    })
  end

  def create
    @item = System::UsersGroup.new(params[:item])
    _create @item
  end

  def edit
    @item = System::UsersGroup.new.find(params[:id])
  end

  def update
    @item = System::UsersGroup.new.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = System::UsersGroup.new.find(params[:id])
    _destroy @item
  end

  def item_to_xml(item, options = {})
    options[:include] = [:user]
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
