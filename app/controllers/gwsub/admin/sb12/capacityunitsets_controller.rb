class Gwsub::Admin::Sb12::CapacityunitsetsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    return redirect_to(url_for(action: :index)) if params[:reset]
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Externalusb.is_dev?
    @role_sysadmin   = Gwsub::Externalusb.is_sysadmin? #_admin
    @role_admin      = Gwsub::Externalusb.is_admin?
    @role_admin = @role_admin || @role_sysadmin
    @u_role = @role_developer || @role_admin

    @menu_header4 = 'capacityunitsets'
    Page.title = @menu_title4  = '外部媒体容量単位'

    # 表示行数　設定
    @limit = nz(params[:limit],30)

    search_condition
    setting_sortkeys
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l4_current='01'
  end
  def search_condition
    params[:limit] = nz(params[:limit],@limit)
    qsa = ['limit', 's_keyword']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sortkeys
    @sort_keys = nz(params[:sort_keys], 'code ASC')
  end

  def index
    init_params
    item = Gwsub::Capacityunitset.new
    item.search params
    item.page   params[:page], params[:limit]
    item.order @sort_keys, 'id ASC'
    @items = item.find(:all)
    _index @items
  end

  def show
    init_params
    @item = Gwsub::Capacityunitset.find(params[:id])
    _show @item
  end

  def new
    init_params
    @l4_current='02'
    @item = Gwsub::Capacityunitset.new
  end
  def create
    init_params
    @l4_current='02'
    @item = Gwsub::Capacityunitset.new(params[:item])

    _create @item
  end

  def edit
    init_params
    @item = Gwsub::Capacityunitset.find(params[:id])
  end
  def update
    init_params
    @item = Gwsub::Capacityunitset.new.find(params[:id])
    @item.attributes = params[:item]

    _update @item
  end

  def destroy
    init_params
    @item = Gwsub::Capacityunitset.find(params[:id])

    _destroy @item
  end

  def csvput
    init_params
    @l4_current='03'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = Gwsub::Capacityunitset.all.to_csv(i18n_key: :default)
    send_data @item.encode(csv), filename: "sb09_capacity_unit_sets_#{@item.encoding}.csv"
  end

  def csvup
    init_params
    @l4_current='04'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    Gwsub::Capacityunitset.transaction do
      Gwsub::Capacityunitset.truncate_table
      items = Gwsub::Capacityunitset.from_csv(@item.file_data, i18n_key: :default)
      items.each {|item| item.save(validate: false) }
    end

    flash[:notice] = '登録処理が完了しました。'
    redirect_to url_for(action: :index)
  end
end
