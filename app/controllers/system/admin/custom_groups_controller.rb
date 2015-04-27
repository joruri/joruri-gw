class System::Admin::CustomGroupsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    @is_gw_admin = Gw.is_admin_admin?
    Page.title = "カスタムグループ設定"
  end

  def index
    @items = load_index_items
    _index @items
  end

  def show
    @item = System::CustomGroup.find(params[:id])
    _show @item
  end

  def new
    @item = System::CustomGroup.new(state: 'enabled')
  end

  def create
    @item = System::CustomGroup.new(params[:item])
    _create @item
  end

  def edit
    @item = System::CustomGroup.find(params[:id])
  end

  def update
    @item = System::CustomGroup.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def sort_update
    @items = load_index_items
    params[:items].each do |id, param|
      item = @items.detect{|i| i.id == id.to_i}
      item.attributes = param if item
    end

    if @items.map(&:valid?).all?
      @items.each(&:save)
      redirect_to url_for(action: :index), notice: '並び順を更新しました。'
    else
      flash.now[:notice] = '並び順の更新に失敗しました。'
      render :index
    end
  end

  def destroy
    @item = System::CustomGroup.find(params[:id])
    _destroy @item
  end

  def get_users
    group = System::Group.find(params[:group_id])
    render text: view_context.options_for_select(group.enabled_user_options)
  end

  def synchro_all_group
    return error_auth unless @is_gw_admin

    cg_sort_no = 100
    system_groups = System::Group.where(state: 'enabled', level_no: 3).order(code: :asc, sort_no: :asc, name: :asc)
    system_groups.each do |s_group|
      c_group = System::CustomGroup.where(state: 'enabled', name: s_group.name, is_default: 1).order(sort_no: :asc).first
      if c_group.blank? && (s_group.parent.present? && s_group.parent.code != '600') && s_group.state == 'enabled'
        System::CustomGroup.create_new_custom_group(System::CustomGroup.new, s_group, cg_sort_no, :create)
        cg_sort_no += 10
      elsif c_group.present? && s_group.state == 'enabled'
        System::CustomGroup.create_new_custom_group(c_group, s_group, cg_sort_no, :update)
        cg_sort_no += 10
      elsif c_group.present? && s_group.state == 'disabled'
        c_group.state = 'disabled'
        c_group.save(validate: false)
      end
    end

    custom_groups = System::CustomGroup.where(state: 'enabled', is_default: 1).order(sort_no: :asc)
    custom_groups.each do |c_group|
      s_group = System::Group.where(state: 'enabled', name: c_group.name).order(sort_no: :asc).first
      if s_group.blank?
        c_group.state = 'disabled'
        c_group.save(validate: false)
      end
    end
    flash_notice 'カスタムグループの同期', true
    #redirect_to '/system/custom_groups'
    redirect_to '/system/group_changes'
  end

  def all_groups_disabled_delete
    return error_auth unless @is_gw_admin

    names = []
    c_groups = System::CustomGroup.where(state: 'disabled', is_default: 1).order(sort_no: :asc)
    c_groups.each do |c_group|
      names << "#{c_group.name}（id：#{c_group.id}）"
      c_group.destroy
    end
    flash_notice "無効となったデフォルトカスタムグループ「#{Gw.join(names, "，")}」の削除", true
    dump "無効となったデフォルトカスタムグループ「#{Gw.join(names, "，")}」の削除成功"
    #redirect_to '/system/custom_groups'
    redirect_to '/system/group_changes'
  end

  private

  def load_index_items
    System::CustomGroup
      .tap {|g| break g.search_with_text(:name, params[:keyword]) if params[:keyword].present? }
      .tap {|g| break g.with_owner_or_admin_role(Core.user) unless @is_gw_admin }
      .order(sort_prefix: :asc, sort_no: :asc, id: :asc)
      .paginate(page: params[:page], per_page: params[:limit])
      .preload(:owner_group, :updater)
  end
end
