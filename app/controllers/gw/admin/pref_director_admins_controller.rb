class Gw::Admin::PrefDirectorAdminsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/pref"

  def pre_dispatch
    @role_developer = Gw::PrefDirector.is_dev?
    @role_admin     = Gw::PrefDirector.is_admin?
    @u_role = @role_developer || @role_admin
    return error_auth unless @u_role

    Page.title = "部課長在庁表示管理"
    @css = %w(/_common/themes/gw/css/admin.css)
  end

  def url_options
    super.merge(params.slice(:g_cat).symbolize_keys)
  end

  def index
    @items =
      if params[:g_cat].present?
        Gw::PrefDirector.where(parent_g_order: params[:g_cat].to_i)
      else
        Gw::PrefDirector.group(:parent_g_order)
      end
    @items = @items.order(parent_g_order: :asc, u_order: :asc).paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Gw::PrefDirector.find(params[:id])
  end

  def new
  end

  def create
  end

  def edit
    @item = Gw::PrefDirector.find(params[:id])
  end

  def update
    @item = Gw::PrefDirector.find(params[:id])
    @item.attributes = item_params
    @item.group_directors.each do|d|
      if d._destroy_flag == '1'
        d.state = 'deleted'
        d.deleted_at = Time.now
        d.deleted_user = Core.user.name
        d.deleted_group = Core.user_group.ou_name
      end
    end
    _update @item
  end

  def destroy
    @item = Gw::PrefDirector.find(params[:id])
    @item.state = 'deleted'
    @item.deleted_at = Time.now
    @item.deleted_user = Core.user.name
    @item.deleted_group = Core.user_group.ou_name

    _update @item, notice: '削除処理が完了しました。'
  end

  def sort_update
    @items = Gw::PrefDirector.where(parent_g_order: params[:g_cat].to_i)
      .order(parent_g_order: :asc, u_order: :asc).paginate(page: params[:page], per_page: params[:limit])

    item_params.each do |id, param|
      item = @items.detect{|i| i.id == id.to_i}
      item.attributes = param.permit(:sort_no) if item
    end

    if @items.map(&:valid?).all?
      @items.each(&:save)
      redirect_to url_for(action: :index), notice: '並び順を更新しました。'
    else
      flash.now[:notice] = '並び順の更新に失敗しました。'
      render :index
    end
  end

  def get_users
    group = System::Group.find(params[:group_id])
    render text: view_context.options_for_select(group.enabled_user_options(ldap: 1))
  end

  def csvput
    @item = System::Model::FileConf.new(encoding: 'sjis')
    if params[:item].present?
      @item.attributes = item_params

      items =
        if @item.extras[:g_cat] == "0"
          Gw::PrefDirector.order(parent_g_order: :asc, g_order: :asc, u_order: :asc)
        else
          Gw::PrefDirector.where(parent_g_code: @item.extras[:g_cat]).order(g_order: :asc, u_order: :asc)
        end

      csv = items.to_csv(headers: ['並び順','職員番号','氏名','職名','部局','Gwに表示']) do |item|
        item_to_csv(item)
      end

      if @item.extras[:g_cat] == "0"
        filename = "部課長在庁表示管理_#{@item.encoding}_#{Time.now.strftime('%Y%m%d_%H%M')}.csv"
      else
        filename = "#{items[0].parent_g_name}_在庁表示管理_#{@item.encoding}_#{Time.now.strftime('%Y%m%d_%H%M')}.csv"
      end
      return send_data @item.encode(csv), type: 'text/csv', filename: filename
    end
  end

  def item_to_csv(item)
    data = [item.u_order, item.u_code, item.u_name, item.title, item.parent_g_name]
    data << (item.is_governor_view == 1 ? '表示' : '')
    data
  end

  def csvup
    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if item_params.nil?

    @item.attributes = item_params
    return unless @item.valid_file?

    begin
      s_to = Gw::Script::PrefTool.import_csv(@item.file_data, "gw_pref_directors_csv", @item.extras[:g_cat])
      flash[:notice] = s_to
    rescue
      flash[:notice] = "CSVファイルの読み込みができませんでした。"
    end

    redirect_to url_for(action: :index)
  end

  def temp_pickup
    @item = Gw::PrefConfig.where(state: 'enabled', option_type: 'directors2', name: 'admin').first_or_create
  end

  def temp_pickup_run
    @item = Gw::PrefConfig.where(state: 'enabled', option_type: 'directors2', name: 'admin').first_or_create

    @item.options = params[:positions].to_s.chomp('・')
    @item.options += ','
    @item.options += params[:select].to_i.to_s


    unless @item.save
      flash[:notice] = "抽出条件の保存に失敗しました。"
      return render :temp_pickup
    end
    status_item = Gw::PrefConfig.where(state: 'enabled', option_type: 'directors3', name: 'admin').first_or_create
    status_item.options = 'prepare'
    status_item.save

    count_item = Gw::PrefConfig.where(state: 'enabled', option_type: 'directors4', name: 'admin').first_or_create
    count_item.options = 0
    count_item.save

    Gw::PrefDirectorTemp.delay.rebuild(@item)
    flash[:notice] = "データの抽出を開始しました。"

    redirect_to url_for(action: :temp_index)
  end

  def temp_index
    @status_item = Gw::PrefConfig.where(state: 'enabled', option_type: 'directors3', name: 'admin').first_or_create
    @count_item = Gw::PrefConfig.where(state: 'enabled', option_type: 'directors4', name: 'admin').first_or_create
    @items =
      if params[:g_cat].present?
        Gw::PrefDirectorTemp.where(parent_g_order: params[:g_cat].to_i)
      else
        Gw::PrefDirectorTemp.group(:parent_g_order)
      end
    @items = @items.order(parent_g_order: :asc, u_order: :asc).paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def temp_csv
    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if item_params.nil?

    @item.attributes = item_params

    csv = Gw::PrefDirectorTemp.where(deleted_at: nil).order(parent_g_order: :asc, u_order: :asc)
      .to_csv(headers: ['並び順','職員番号','氏名','職名','部局','Gwに表示']) {|item| item_to_csv(item) }

    send_data @item.encode(csv), type: 'text/csv', filename: "部課長在庁表示管理_仮一覧_#{@item.encoding}_#{Time.now.strftime('%Y%m%d_%H%M')}.csv"
  end


private

  def item_params
    params.require(:item).permit!
  end


end
