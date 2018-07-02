class Gw::Admin::EditTabsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @role_developer = Gw::EditTab.is_dev?
    @role_admin = Gw::EditTab.is_admin?
    @role_editor = Gw::EditTab.is_editor?
    @u_role = @role_developer || @role_admin || @role_editor
    return error_auth unless @u_role

    @parent = params[:pid].present? ? Gw::EditTab.find_by(id: params[:pid]) : Gw::EditTab.root
    return http_error(404) unless @parent

    Page.title = "タブ編集"
  end

  def url_options
    super.merge(params.slice(:pid).symbolize_keys)
  end

  def index
    @items = Gw::EditTab.where(parent_id: @parent.id).order(:sort_no)
      .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Gw::EditTab.find(params[:id])
  end

  def new
    @item = Gw::EditTab.new(
      parent_id: @parent.id,
      level_no: @parent.level_no + 1,
      state: 'enabled',
      published: 'opened',
      tab_keys: 0,
      sort_no: Gw::EditTab.where(parent_id: @parent.id).maximum(:sort_no).to_i + 10,
      class_created: 1,
      class_external: 0,
      class_sso: '1',
      is_public: 0
    )
  end

  def create
    @item = Gw::EditTab.new(params[:item])
    _create @item
  end

  def edit
    @item = Gw::EditTab.find(params[:id])
  end

  def update
    @item = Gw::EditTab.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = Gw::EditTab.find(params[:id])
    @item.published      = 'closed'
    @item.state          = 'deleted'
    @item.tab_keys       = nil
    @item.sort_no        = nil
    @item.deleted_at     = Time.now
    @item.deleted_user   = Core.user.name
    @item.deleted_group  = Core.user_group.name
    @item.save(validate: false)

    redirect_to url_for(action: :index), notice: "削除処理が完了しました。"
  end
  def sort_update
    @items = Gw::EditTab.where(parent_id: @parent.id).order(:sort_no)
    params[:items].each do |id, param|
      item = @items.detect{|i| i.id == id.to_i}
      item.attributes = param if item
    end

    if @items.map(&:valid?).all?
      @items.each(&:save)
      redirect_to url_for(action: :index, pid: @parent.id), notice: '並び順を更新しました。'
    else
      flash.now[:notice] = '並び順の更新に失敗しました。'
      render :index
    end
  end

  def list
    @items = Gw::EditTab.where(level_no: 2).order(state: :desc, sort_no: :asc)
  end

  def getajax
    group = System::Group.find(params[:group_id])
    options = group.self_and_enabled_descendants.map{|g| [g.name, g.id]}
    render text: view_context.options_for_select(options)
  end
end
