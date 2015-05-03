class System::Admin::RoleDevelopersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @is_dev = System::Role.is_dev?
    @is_admin = System::Role.is_admin?
    return error_auth unless @is_dev

    Page.title = "開発者権限設定"
  end

  def index
    @items = System::Role.includes(:role_name, :user, :group).where(priv_name: "developer")
      .order('system_role_names.sort_no, priv_name, idx, class_id, system_users.code, system_groups.sort_no, system_groups.code')
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = System::Role.find(params[:id])
  end

  def new
    priv = System::PrivName.where(priv_name: 'developer').first
    return http_error(404) unless priv

    @item = System::Role.new(
      priv_user_id: priv.id,
      class_id: 1,
      priv: 1,
      group_id: Core.user_group.id,
      uid: Core.user.id
    )
  end

  def create
    @item = System::Role.new(params[:item])
    _create @item
  end

  def edit
    @item = System::Role.find(params[:id])
  end

  def update
    @item = System::Role.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = System::Role.find(params[:id])
    _destroy @item
  end
end
