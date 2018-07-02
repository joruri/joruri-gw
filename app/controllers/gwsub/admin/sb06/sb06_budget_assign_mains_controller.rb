class Gwsub::Admin::Sb06::Sb06BudgetAssignMainsController  < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch

    return redirect_to(url_for(action: :index)) if params[:reset]

    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "予算担当主管課登録"
  end

  def index
    init_params
    # 初期化
    if params[:do]=='init'
      Gwsub::Sb06BudgetAssignMain.truncate_table
    end
    item = Gwsub::Sb06BudgetAssignMain.new #.readable
    item.search params
#    item.creator
    item.page   params[:page], params[:limit]
    item.order @sort_keys, 'id ASC'
    @items = item.find(:all)
#pp params,@items
    _index @items
  end
  def show
    init_params
    @item = Gwsub::Sb06BudgetAssignMain.find(params[:id])
  end

  def new
    init_params
    @l3_current ='02'
    @item = Gwsub::Sb06BudgetAssignMain.new({
        :group_id       =>  Core.user_group.id ,
        :user_id        =>  Core.user.id ,
        :budget_role_id => @b_role_id,
        :multi_sequence => '',
        :main_state     => '1',
        :admin_state    => '2'
      })
  end
  def create
    init_params
    @l3_current ='02'
    @item = Gwsub::Sb06BudgetAssignMain.new(params[:item])
    @item.multi_group_id = @item.group_id
    location = url_for({:action => :index})
    options = {
      :success_redirect_uri=>location,
    }
    _create(@item,options)
  end

  def edit
    init_params
    @item = Gwsub::Sb06BudgetAssignMain.find(params[:id])
  end
  def update
    init_params
    @item = Gwsub::Sb06BudgetAssignMain.find(params[:id])
    params[:item]['multi_group_id'] = @item.group_id
    @item.attributes = params[:item]
    location = url_for({:action => :show, :id => params[:id]})
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

  def destroy
    init_params
    @item = Gwsub::Sb06BudgetAssignMain.find(params[:id])
    location = url_for({:action => :index})
    options = {
      :success_redirect_uri=>location
    }
    _destroy(@item,options)
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb06BudgetRole.is_dev?
    @role_admin      = Gwsub::Sb06BudgetRole.is_admin?
    @u_role           = @role_developer || @role_admin
    # 予算担当　管理者
    @budget_admin     = Gwsub::Sb06BudgetRole.budget_admin?
    # 予算担当　主管課
    @budget_main      = Gwsub::Sb06BudgetRole.budget_main?

    @menu_header3 = 'sb06_budget_assign_mains'
    @menu_title3  = '主管課登録'

    # 所属選択　設定
    @group_id = nz(params[:group_id],0)
    # 権限選択
    role = Gwsub::Sb06BudgetRole.where(:code=>'4').order("code").first
    role_id = role.blank? ? nil : role.id
    @b_role_id = nz(params[:b_role_id],role_id)
    # 表示行数　設定
    @limit = nz(params[:limit],30)

    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current ='03'
    @l2_current ='01'
    @l3_current ='01'
  end

  def search_condition
#    params[:fyed_id] = nz(params[:fyed_id],@fyed_id)
    params[:group_id]   = nz(params[:group_id],@group_id)
    params[:b_role_id]  = nz(params[:b_role_id],@b_role_id)
    params[:limit]      = nz(params[:limit], @limit)

    qsa = ['limit', 's_keyword' ,'group_id','b_role_id']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def sortkeys_setting
#    @sort_keys = nz(params[:sort_keys], 'group_code , multi_user_code')
    @sort_keys = nz(params[:sort_keys], 'group_parent_code , group_code , user_code')
  end

  def user_fields
    users = System::User.get_user_select(params[:g_id])
    render text: view_context.options_for_select(users), layout: false
  end
end
