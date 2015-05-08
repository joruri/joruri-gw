class System::Admin::UsersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    @role_developer  = System::User.is_dev?
    @role_admin      = System::User.is_admin?
    @role_editor     = System::User.is_editor?
    @u_role = @role_developer || @role_admin || @role_editor
    return error_auth unless @u_role

    @css = %w(/layout/admin/style.css)
    Page.title = "ユーザー・グループ管理"
  end

  def url_options
    super.merge(params.slice(:ldap, :state, :group_id, :limit, :s_keyword).symbolize_keys)
  end

  def index
    params[:limit] ||= '30'
    params[:state] ||= 'enabled'

    items = System::User.eager_load(:groups)
    items = items.where(ldap: params[:ldap]) if params[:ldap].present?
    items = items.where(state: params[:state]) if params[:state].present?
    items = items.where(System::UsersGroup.arel_table[:group_id].eq(nil_or_string(params[:group_id]))) if params[:group_id].present?
    items = items.search_with_text(:code, :name, :name_en, :email, params[:s_keyword]) if params[:s_keyword].present?
    @items = items.order(code: :asc).paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = System::User.find(params[:id])
  end

  def new
    @item = System::User.new(state: 'enabled', ldap: 0)
  end

  def create
    @item = System::User.new(params[:item])
    @item.user_groups.each {|ug| ug.user = @item } # for user_groups validation
    _create @item
  end

  def edit
    @item = System::User.find(params[:id])
  end

  def update
    @item = System::User.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = System::User.find(params[:id])
    @item.state = 'disabled'
    _update @item, notice: 'ユーザーを無効状態にしました。'
  end

  def list
    Page.title = "ユーザー・グループ 全一覧画面"
    @groups = System::Group.roots
  end

private

  def nil_or_string(str)
    str == 'nil' ? nil : str
  end
end
