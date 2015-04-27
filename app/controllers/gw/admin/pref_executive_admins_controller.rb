class Gw::Admin::PrefExecutiveAdminsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/pref"

  def pre_dispatch
    @role_developer = Gw::PrefExecutive.is_dev?
    @role_admin     = Gw::PrefExecutive.is_admin?
    @u_role = @role_developer || @role_admin
    return error_auth unless @u_role
    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    Page.title = "全庁幹部在庁表示管理"
    @css = %w(/_common/themes/gw/css/admin.css)
  end

  def index
    @items = Gw::PrefExecutive.order(u_order: :asc, id: :asc)
      .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def new
    @items = Gw::PrefExecutive.order(u_order: :asc, id: :asc)
  end

  def create
    @items = Gw::PrefExecutive.order(u_order: :asc, id: :asc)
    @items = params[:items].values.map do |param|
      item = @items.detect{|i| i.id == param[:id].to_i} || Gw::PrefExecutive.new(state: 'off')
      item.attributes = param.except(:id)
      item
    end

    if @items.select{|item| item._destroy_flag != '1'}.map(&:valid?).all?
      Gw::PrefExecutive.transaction do
        @items.each do |item|
          if item._destroy_flag == '1'
            if item.persisted?
              item.state = 'deleted'
              item.deleted_at = Time.now
              item.deleted_user = Core.user.name
              item.deleted_group = Core.user_group.ou_name
              item.save(validate: false)
            end
          else
            item.save
          end
        end
      end
      redirect_to url_for(action: :index), notice: '登録処理が完了しました。'
    else
      render :new
    end
  end

  def destroy
    @item = Gw::PrefExecutive.find(params[:id])
    @item.state = 'deleted'
    @item.deleted_at = Time.now
    @item.deleted_user = Core.user.name
    @item.deleted_group = Core.user_group.name

    _update @item, notice: '削除処理が完了しました。'
  end

  def sort_update
    @items = Gw::PrefExecutive.order(u_order: :asc, id: :asc)
      .paginate(page: params[:page], per_page: params[:limit])

    params[:item].each do |id, param|
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

  def csvput
    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = Gw::PrefExecutive.order(:u_order).to_csv(headers: ["並び順","職員番号","氏名","職名","Gwに表示","AIRに表示"]) do |item|
      data = [item.u_order, item.u_code, item.u_name, item.title]
      data << (item.is_other_view == 1 ? "表示" : "")
      data << (item.is_governor_view == 1 ? "表示" : "")
    end

    send_data @item.encode(csv), type: 'text/csv', filename: "全庁幹部在庁表示_#{@item.encoding}_#{Time.now.strftime('%Y%m%d_%H%M')}.csv"
  end

  def csvup
    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    begin
      s_to = Gw::Script::PrefTool.import_csv(@item.file_data, "gw_pref_executive_csv")
      flash[:notice] = "CSVファイルの読み込みが完了しました。"
    rescue
      flash[:notice] = "CSVファイルの読み込みに失敗しました。"
    end

    redirect_to url_for(action: :index)
  end

  def get_users
    group = System::Group.find(params[:group_id])
    render text: view_context.options_for_select(group.enabled_user_options(ldap: 1))
  end
end
