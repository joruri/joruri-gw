class System::Admin::UsersGroupsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @role_admin = System::User.is_admin?
    return error_auth unless @role_admin

    @current_no = 2
    id      = params[:parent] == '0' ? 1 : params[:parent]
    @parent = System::Group.where(:id => id).first
    return http_error(404) if @parent.blank?

    params[:limit] = Gw.nz(params[:limit],30)
    Page.title = "ユーザー・グループ管理"
  end

  def index
    @items = System::UsersGroup.where(group_id: @parent.id)
      .paginate(page: params[:page],per_page: params[:per_page])
      .order(user_code: :asc)

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
    @item = System::UsersGroup.new(user_group_params)
    _create @item
  end

  def edit
    @item = System::UsersGroup.new.find(params[:id])
  end

  def update
    @item = System::UsersGroup.new.find(params[:id])
    @item.attributes = user_group_params
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
    Page.title = "ユーザー・グループ 全一覧画面"

    @groups = System::Group.get_level2_groups
  end

private

  def user_group_params
    params.require(:item).permit(:user_id, :group_id, :job_order, :start_at, :end_at)
  end

end
