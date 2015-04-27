class Gwsub::Admin::Sb06::Sb06AssignedConfItemsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch

    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "40申請書項目"
    init_params
    return error_auth unless @u_role == true
  end

  def index

#    pp params
    item = Gwsub::Sb06AssignedConfItem.new
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end
  def show

    @item = Gwsub::Sb06AssignedConfItem.find(params[:id])
  end

  def new

    @l3_current = '02'
    @item = Gwsub::Sb06AssignedConfItem.new
    @item.fyear_id = @fy_id
    @item.select_list=1
  end
  def create

    @l3_current = '02'
    @item = Gwsub::Sb06AssignedConfItem.new(params[:item])
    location = url_for({:action => :index})
    _create(@item,:success_redirect_uri=>location)
  end

  def edit

    @item = Gwsub::Sb06AssignedConfItem.find(params[:id])
  end
  def update

    @item = Gwsub::Sb06AssignedConfItem.new.find(params[:id])
    @item.attributes = params[:item]
    location = url_for({:action => :index})
    _update(@item,:success_redirect_uri=>location)
  end

  def destroy
    @item = Gwsub::Sb06AssignedConfItem.new.find(params[:id])
    location = url_for({:action => :index})
    _destroy(@item,:success_redirect_uri=>location)
  end

  def csvput
    @l3_current = '03'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = Gwsub::Sb06AssignedConfItem.all.to_csv(i18n_key: :default)
    send_data @item.encode(csv), filename: "sb06_assigned_conf_items_#{@item.encoding}.csv"
  end

  def csvup
    @l3_current = '04'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    Gwsub::Sb06AssignedConfItem.transaction do
      Gwsub::Sb06AssignedConfItem.truncate_table
      items = Gwsub::Sb06AssignedConfItem.from_csv(@item.file_data, i18n_key: :default)
      items.each(&:save)
    end
    flash[:notice] = '登録処理が完了しました。'
    redirect_to action: :index
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb06AssignedConference.is_dev?
    @role_admin      = Gwsub::Sb06AssignedConference.is_admin?
    @u_role = @role_developer || @role_admin
    @role_editor     = Core.user_group.code

    @menu_header3 = 'sb0606menu'
    @menu_title3  = 'コード管理'
    @menu_header4 = 'sb06_assigned_conf_items'
    @menu_title4  = '申請書項目'
    # 年度設定
    order = "fyear_id DESC , group_code ASC"
    fyear_id = Gw::YearFiscalJp.get_record(Time.now)
    fyear_id = fyear_id.blank? ? 0 : fyear_id.id
    @fy_id  = nz(params[:fy_id],fyear_id)
#    @fy_id  = nz(params[:fy_id],0)
    # 所属設定
    @c_group_id  = nz(params[:c_group_id],0)
    # 申請書種別設定
    @c_kind_id  = nz(params[:c_kind_id],0)
    # 表示行数　設定
    @limit  = nz(params[:limit],30)

    search_condition
    setting_sortkeys
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current = '04'
    @l2_current = '01'
    @l3_current = '01'

    return
  end
  def search_condition
    params[:fy_id]      = nz(params[:fy_id], @fy_id)
    params[:c_group_id] = nz(params[:c_group_id], @c_group_id)
    params[:c_kind_id]  = nz(params[:c_kind_id], @c_kind_id)
    params[:limit]      = nz(params[:limit], @limit)

    qsa = ['limit', 's_keyword' ,'fy_id', 'c_group_id' , 'c_kind_id']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sortkeys
    @sort_keys = nz(params[:sort_keys], 'item_sort_no ASC')
  end

  def conf_kinds_select
    conf_kind_options = {c_group_id: params[:gid].to_i, fyear_id: params[:fyid].to_i}
    conf_kind_options[:all] = "all" if params[:all]
    conf_kinds = Gwsub::Sb06AssignedConfKind.sb06_assign_conf_kind_id_select(conf_kind_options)
    render text: view_context.options_for_select(conf_kinds), layout: false
  end
end
