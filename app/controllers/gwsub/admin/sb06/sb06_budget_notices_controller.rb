class Gwsub::Admin::Sb06::Sb06BudgetNoticesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch

    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "00予算担当説明"
  end

  def index
    init_params
    unless @u_role==true
      @v           = '2'
      params[:v]  = '2'
    end
    # 表示対象の絞込
    # 一般
    @kind='1'
    # 主管課
    @kind='2' if @budget_main==true
    # 管理者
    @kind='3' if @budget_admin==true
    @kind='3' if @u_role==true
    # ヘルプ状態（1:有効、2:無効）
    @help_state = '1'
    @help_state = '2' unless @v=='2'

    item = Gwsub::Sb06BudgetNotice.new #.readable
    item.and 'sql',"kind<='#{@kind}'"
    item.and 'sql',"state<='#{@help_state}'"

    if @v=='2'
      if @budget_admin
        item.and 'sql',"kind<='3'"
      elsif @budget_main
        item.and 'sql',"kind<='2'"
      else
        item.and 'sql',"kind<='1'"
      end
    end

#    item.search params
#    item.creator
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
#pp params,@items
    _index @items
  end
  def show
    init_params
    unless @u_role==true
      location  = "/gwsub/sb06/sb06_budget_notices?v=2"
      redirect_to location
    end
    @item = Gwsub::Sb06BudgetNotice.find(params[:id])
  end

  def new
    init_params
    unless @u_role==true
      location  = "/gwsub/sb06/sb06_budget_notices?v=2"
      redirect_to location
    end
    case @v
    when '2'
      @l1_current='02'
      @l2_current='01'
    else
      @l1_current='03'
      @l2_current='05'
      @l3_current='02'
    end
    @item = Gwsub::Sb06BudgetNotice.new
    # 選択初期値　kind(種別)：一般用、state(状態)：有効
    @item.kind  = '1'
    @item.state = '1'
  end
  def create
    init_params
    unless @u_role==true
      location  = "/gwsub/sb06/sb06_budget_notices?v=2"
      redirect_to location
    end
    case @v
    when '2'
      @l1_current='02'
      @l2_current='01'
    else
      @l1_current='03'
      @l2_current='05'
      @l3_current='02'
    end
    @item = Gwsub::Sb06BudgetNotice.new(params[:item])
#    @item = Sb06BudgetNotice.new(params[:item])
    location =url_for({:action => :index})
    options = {
      :success_redirect_uri=>location,
    }
    _create(@item,options)
  end

  def edit
    init_params
    unless @u_role==true
      location  = "/gwsub/sb06/sb06_budget_notices?v=2"
      redirect_to location
    end
    @item = Gwsub::Sb06BudgetNotice.find(params[:id])
  end
  def update
    init_params
    unless @u_role==true
      location  = "/gwsub/sb06/sb06_budget_notices?v=2"
      redirect_to location
    end
    @item = Gwsub::Sb06BudgetNotice.find(params[:id])
    @item.attributes = params[:item]
    location = url_for({:action => :show, :id => params[:id]})
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

  def destroy
    init_params
    unless @u_role==true
      location  = "/gwsub/sb06/sb06_budget_notices?v=2"
      redirect_to location
    end
    @item = Gwsub::Sb06BudgetNotice.find(params[:id])
    location = url_for({:action => :index})
    options = {
      :success_redirect_uri=>location,
    }
    _destroy(@item,options)
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb06BudgetRole.is_dev?
    @role_admin      = Gwsub::Sb06BudgetRole.is_admin?
    @u_role = @role_developer || @role_admin
    # 予算担当　管理者
    @budget_admin     = Gwsub::Sb06BudgetRole.budget_admin?
    # 予算担当　主管課
    @budget_main      = Gwsub::Sb06BudgetRole.budget_main?
    # 予算ヘルプ権限
    item = Gwsub::Sb06BudgetAssign.new
    item.and :user_id, Core.user.id
    @budget_a = item.find(:first)

    @menu_header3 = 'sb0605menu'
    @menu_title3  = 'コード管理'
    @menu_header4 = 'sb06_budget_notices'
    @menu_title4  = '説明管理'
    # 表示形式
    @v = nz(params[:v],@u_role==true ? '1':'2')
    if @v == '2'
      @menu_header3 = 'sb06_budget_notices'
      @menu_title3  = '説明'
      @menu_header4 = nil
      @menu_title4  = nil
    end

    @bbs_link_title  = '別ウィンドウ・別タブで説明記事を開きます'
    # 年度選択　設定
      # 年度変更時は、所属選択をクリア
#    if params[:fyed_id]
#      if params[:pre_fyear] != params[:fyed_id]
#        params[:grped_id] = 0
#      end
#    else
#        params[:grped_id] = 0
#    end
    # 年度選択　設定
#    @fyed_id = Gwsub.set_fyear_select(params[:fyed_id])
    # 所属選択　設定
#    @grped_id = Gwsub.set_section_select(@fyed_id , params[:grped_id])
    # 表示行数　設定
    @limits = nz(params[:limit],30)
    # 表示形式
    @v = nz(params[:v],'1')

    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    case @v
    when '2'
      @l1_current='02'
      @l2_current='01'
    else
      @l1_current='03'
      @l2_current='05'
      @l3_current='01'
    end
  end

  def search_condition
#    params[:fyed_id] = nz(params[:fyed_id],@fyed_id)
#    params[:grped_id] = nz(params[:grped_id],@grped_id)
    params[:limit] = nz(params[:limit], @limits)

    qsa = ['limit', 's_keyword'  ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'kind , bbs_url ASC')
  end

end
