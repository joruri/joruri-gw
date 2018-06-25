class Gwsub::Admin::Sb06::Sb06BudgetEditableDatesController  < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch

    return redirect_to(url_for(action: :index)) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "40予算担当編集期限"
  end

  def index
    init_params
    item = Gwsub::Sb06BudgetEditableDate.new #.readable
    item.search params
#    item.creator
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
#pp params,@items
    _index @items
  end
  def show
    init_params
    @item = Gwsub::Sb06BudgetEditableDate.find(params[:id])
  end

  def new
    init_params
    @l3_current ='02'
    @item = Gwsub::Sb06BudgetEditableDate.new
  end
  def create
    init_params
    @l3_current ='02'
    new_item = Gwsub::Sb06BudgetEditableDate.set_f(params[:item])
    @item = Gwsub::Sb06BudgetEditableDate.new(new_item)
    location = url_for({:action => :index})
    options = {
      :success_redirect_uri=>location,
    }
    _create(@item,options)
  end

  def edit
    init_params
    @item = Gwsub::Sb06BudgetEditableDate.find(params[:id])
  end
  def update
    init_params
    @item = Gwsub::Sb06BudgetEditableDate.find(params[:id])
    new_item = Gwsub::Sb06BudgetEditableDate.set_f(params[:item])
    @item.attributes = new_item
    location = url_for({:action => :show, :id => params[:id]})
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

  def destroy
    init_params
    @item = Gwsub::Sb06BudgetEditableDate.find(params[:id])
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

    @menu_header3 = 'sb0605menu'
    @menu_title3  = 'コード管理'
    @menu_header4 = 'sb06_budget_editable_dates'
    @menu_title4  = '期限設定'
    # 表示行数　設定
    @limit = nz(params[:limit],30)

    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current ='03'
    @l2_current ='06'
    @l3_current ='01'
  end

  def search_condition
    params[:limit]    = nz(params[:limit], @limits)

    qsa = ['limit', 's_keyword' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'start_at DESC')
  end

end
