class Gwsub::Admin::Sb13::ExternalmediakindsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    return redirect_to(url_for(action: :index)) if params[:reset]
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Externalmedia.is_dev?
    @role_sysadmin   = Gwsub::Externalmedia.is_sysadmin? #_admin
    @role_admin      = Gwsub::Externalmedia.is_admin?
    @role_admin = @role_admin || @role_sysadmin
    @u_role = @role_developer || @role_admin

    @menu_header4 = 'externalmediakinds'
    Page.title = @menu_title4  = '外部媒体区分'

    # 表示行数　設定
    @limit = nz(params[:limit],30)

    search_condition
    sortkey_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l4_current='01'
  end
  def search_condition
    params[:limit]          = nz(params[:limit], @limit)

    qsa = ['limit', 's_keyword']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def sortkey_setting
    @sort_keys = nz(params[:sort_keys], 'sort_order_int ASC')
  end

  def index
    init_params
    item = Gwsub::Externalmediakind.new
    item.search params
    item.page   params[:page], params[:limit]
    item.order @sort_keys, 'id ASC'
    @items = item.find(:all)
    _index @items
  end

  def show
    init_params
    @item = Gwsub::Externalmediakind.find(params[:id])
    _show @item
  end

  def new
    init_params
    @l4_current='02'
    @item = Gwsub::Externalmediakind.new
  end
  def create
    init_params
    @l4_current='02'
    @item = Gwsub::Externalmediakind.new(media_kind_params)

    _create @item
  end

  def edit
    init_params
    @item = Gwsub::Externalmediakind.find(params[:id])
  end
  def update
    init_params
    @item = Gwsub::Externalmediakind.new.find(params[:id])
    @item.attributes = media_kind_params

    _update @item
  end

  def destroy
    init_params
    @item = Gwsub::Externalmediakind.find(params[:id])

    _destroy @item
  end

  def csvput
    init_params
    @l4_current='03'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = Gwsub::Externalmediakind.all.to_csv(i18n_key: :default)
    send_data @item.encode(csv), filename: "sb09_external_media_kinds_#{@item.encoding}.csv"
  end

  def csvup
    init_params
    @l4_current='04'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    Gwsub::Externalmediakind.transaction do
      Gwsub::Externalmediakind.truncate_table
      items = Gwsub::Externalmediakind.from_csv(@item.file_data, i18n_key: :default)
      items.each {|item| item.save(validate: false) }
    end

    flash[:notice] = '登録処理が完了しました。'
    redirect_to url_for(action: :index)
  end

private

  def media_kind_params
    params.require(:item).permit(:kind, :name, :sort_order)
  end

end
