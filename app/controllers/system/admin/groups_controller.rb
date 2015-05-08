class System::Admin::GroupsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    @role_admin = System::User.is_admin?
    return error_auth unless @role_admin

    if params[:parent].blank? || params[:parent] == '0'
      @parent = System::Group.root
    else
      @parent = System::Group.find(params[:parent])
    end
    return http_error(404) unless @parent

    Page.title = "ユーザー・グループ管理"
  end

  def url_options
    super.merge(params.slice(:ldap, :state).symbolize_keys)
  end

  def index
    params[:state] ||= 'enabled'

    items = System::Group.where(parent_id: @parent.id)
    items = items.where(ldap: params[:ldap]) if params[:ldap].present?
    items = items.where(state: params[:state]) if params[:state].present?
    items = items.search_with_text(:code, :name, :name_en, :email, params[:s_keyword]) if params[:s_keyword].present?
    @items = items.order(sort_no: :asc, code: :asc)
      .paginate(page: params[:page], per_page: params[:limit])
    
    _index @items
  end

  def show
    @item = System::Group.find(params[:id])
    _show @item
  end

  def new
    @item = System::Group.new(
      parent_id: @parent.id,
      state: 'enabled',
      level_no: @parent.level_no.to_i + 1,
      version_id: @parent.version_id.to_i,
      start_at: Date.today,
      sort_no: @parent.sort_no.to_i,
      ldap: 0
    )
  end

  def create
    @item = System::Group.new(params[:item])
    @item.parent_id = @parent.id
    @item.level_no = @parent.level_no.to_i + 1
    @item.version_id = @parent.version_id.to_i
    _create @item
  end

  def update
    @item = System::Group.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = System::Group.find(params[:id])

    if @item.disableable?
      @item.state = 'disabled'
      @item.end_at = Date.today
      _update @item, location: url_for(action: :show), notice: '無効にしました。'
    else
      redirect_to url_for(action: :show), notice: 'ユーザーが所属しているか、下位に有効な所属があるときは、無効にできません。'
    end
  end

  def list
    Page.title = "ユーザー・グループ 全一覧画面"
    @groups = System::Group.roots
  end
end
