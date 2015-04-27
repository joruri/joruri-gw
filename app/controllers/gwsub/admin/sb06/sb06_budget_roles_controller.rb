class Gwsub::Admin::Sb06::Sb06BudgetRolesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch

    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "10予算担当処理権限"
  end

  def index
    init_params
    unless @u_role==true
      location  = "/gwsub/sb06/sb06_budget_assigns"
      redirect_to location
    end
#    pp params
    item = Gwsub::Sb06BudgetRole.new
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end
  def show
    init_params
    unless @u_role==true
      location  = "/gwsub/sb06/sb06_budget_assigns"
      redirect_to location
    end
    @item = Gwsub::Sb06BudgetRole.find(params[:id])
  end

  def new
    init_params
    unless @u_role==true
      location  = "/gwsub/sb06/sb06_budget_assigns"
      redirect_to location
    end
    @l3_current = '02'
    @item = Gwsub::Sb06BudgetRole.new
  end
  def create
    init_params
    unless @u_role==true
      location  = "/gwsub/sb06/sb06_budget_assigns"
      redirect_to location
    end
    @l3_current = '02'
    @item = Gwsub::Sb06BudgetRole.new(params[:item])
    location = url_for({:action => :index})
    _create(@item,:success_redirect_uri=>location)
  end

  def edit
    init_params
    unless @u_role==true
      location  = "/gwsub/sb06/sb06_budget_assigns"
      redirect_to location
    end
    @l3_current = '01'
    @item = Gwsub::Sb06BudgetRole.find(params[:id])
  end
  def update
    init_params
    unless @u_role==true
      location  = "/gwsub/sb06/sb06_budget_assigns"
      redirect_to location
    end
    @l3_current = '01'
    @item = Gwsub::Sb06BudgetRole.new.find(params[:id])
    @item.attributes = params[:item]
    location = url_for({:action => :index})
    _update(@item,:success_redirect_uri=>location)
  end

  def destroy
    init_params
    unless @u_role==true
      location  = "/gwsub/sb06/sb06_budget_assigns"
      redirect_to location
    end
    @l3_current = '01'
    @item = Gwsub::Sb06BudgetRole.new.find(params[:id])
    location = url_for({:action => :index})
    _destroy(@item,:success_redirect_uri=>location)
  end

  def csvput
    init_params
    unless @u_role==true
      location  = "/gwsub/sb06/sb06_budget_assigns"
      redirect_to location
    end
    @l3_current = '03'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = Gwsub::Sb06BudgetRole.all.to_csv(i18n_key: :default)
    send_data @item.encode(csv), filename: "sb06_budget_roles_#{@item.encoding}.csv"
  end

  def csvup
    init_params
    unless @u_role==true
      location  = "/gwsub/sb06/sb06_budget_assigns"
      redirect_to location
    end
    @l3_current = '04'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    Gwsub::Sb06BudgetRole.transaction do
      Gwsub::Sb06BudgetRole.truncate_table
      items = Gwsub::Sb06BudgetRole.from_csv(@item.file_data, i18n_key: :default)
      items.each(&:save)
    end

    flash[:notice] = '登録処理が完了しました'
    redirect_to action: :index
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb06BudgetRole.is_dev?
    @role_admin      = Gwsub::Sb06BudgetRole.is_admin?
    @u_role = @role_developer || @role_admin
    @role_editor     = Core.user_group.code
    # 予算担当　管理者
    @budget_admin     = Gwsub::Sb06BudgetRole.budget_admin?
    # 予算担当　主管課
    @budget_main      = Gwsub::Sb06BudgetRole.budget_main?

    @menu_header3 = 'sb0605menu'
    @menu_title3  = 'コード管理'
    @menu_header4 = 'sb06_budget_roles'
    @menu_title4  = '処理権限'
    # 表示行数　設定
    @limit = nz(params[:limit],30)

    search_condition
    setting_sortkeys
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current = '03'
    @l2_current = '03'
    @l3_current = '01'
    return
  end
  def search_condition
    params[:limit]      = nz(params[:limit], @limit)
    qsa = ['limit', 's_keyword' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sortkeys
    @sort_keys = nz(params[:sort_keys], 'code ASC')
  end

end
