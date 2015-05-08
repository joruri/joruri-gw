class System::Admin::UsersGroupsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @role_admin = System::User.is_admin?
    return error_auth unless @role_admin

    if params[:parent].blank? || params[:parent] == '0'
      @parent = System::Group.root
    else
      @parent = System::Group.find(params[:parent])
    end
    return http_error(404) unless @parent

    params[:limit] ||= 30
    Page.title = "ユーザー・グループ管理"
  end

  def index
    @items = System::UsersGroup.where(group_id: @parent.id).order(user_code: :asc)
      .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = System::UsersGroup.find(params[:id])
    _show @item
  end

  def new
    @item = System::UsersGroup.new(
      group_id: @parent.id,
      job_order: 0,
      start_at: Date.today
    )
    @item.user_id = params[:user_id] if params[:user_id].present?
  end

  def create
    @item = System::UsersGroup.new(params[:item])
    _create @item
  end

  def edit
    @item = System::UsersGroup.find(params[:id])
  end

  def update
    @item = System::UsersGroup.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = System::UsersGroup.find(params[:id])
    _destroy @item
  end

  def list
    Page.title = "ユーザー・グループ 全一覧画面"
    @groups = System::Group.roots
  end
end
