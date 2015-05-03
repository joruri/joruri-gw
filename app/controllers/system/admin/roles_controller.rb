class System::Admin::RolesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    return redirect_to system_roles_path if params[:reset]

    @is_dev = System::Role.is_dev?
    @is_admin = System::Role.is_admin?
    return error_auth unless @is_admin || @is_dev

    Page.title = "権限設定"
  end

  def url_options
    super.merge(params.slice(:role_id).symbolize_keys)
  end

  def index
    items = System::Role.includes(:role_name, :group, :user).where.not(priv_name: 'developer')
    items = items.where(role_name_id: params[:role_id]) if params[:role_id].present?
    @items = items.order('system_role_names.sort_no, priv_name, idx, class_id, system_users.code, system_groups.sort_no, system_groups.code')
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = System::Role.find(params[:id])
  end

  def new
    @item = System::Role.new(
      class_id: 1,
      priv: 1,
      group_id: Core.user_group.id,
      uid: Core.user.id
    )
    @item.role_name_id = params[:role_id] if params[:role_id].present?
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

  def user_fields
    users = System::User.get_user_select(params[:g_id])
    render text: view_context.options_for_select(users), layout: false
  end
end
