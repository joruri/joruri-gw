class Gwsub::Admin::Sb06::Sb06BudgetAssignsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch

    return redirect_to(url_for(action: :index)) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "予算担当登録"
  end

  def index
    init_params
    # 主管課一括承認
    if params[:do]=='recognize_main'
      update_main_state
    end
    # 管理者一括承認
    if params[:do]=='recognize_admin'
      update_admin_state
    end
    # 表示対象の絞込
    if @budget_admin==true
        index_admin
    else
      if @budget_main==true
        index_main
      else
        index_normal
      end
    end
    _index @items
  end
  def show
    init_params
    @item = Gwsub::Sb06BudgetAssign.find(params[:id])
  end

  def new
    init_params
    @l2_current = '02'
    ug = Core.user_group
    g = System::GroupHistory.find(ug.id)
    @item = Gwsub::Sb06BudgetAssign.new({
        :group_parent_id  => g.parent_id ,
        :group_id         => g.id ,
        :user_id        => Core.user.id,
        :multi_sequence => nil,
        :main_state     => '2',
        :admin_state    => '2'
      })
  end
  def create
    init_params
    @l2_current = '02'
    @item = Gwsub::Sb06BudgetAssign.new(params[:item])
    location = url_for({:action => :index})
    options = {
      :success_redirect_uri=>location,
    }
    _create(@item,options)
  end

  def edit
    init_params
    @item = Gwsub::Sb06BudgetAssign.find(params[:id])
  end
  def update
    init_params
    @item = Gwsub::Sb06BudgetAssign.find(params[:id])
    @item.attributes = params[:item]
    location = url_for({:action => :show , :id => params[:id]})
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

  def destroy
    init_params
    @item = Gwsub::Sb06BudgetAssign.find(params[:id])
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
    # システム管理者　または開発者
    @u_role = @role_developer || @role_admin
    # 予算担当　管理者
    @budget_admin     = Gwsub::Sb06BudgetRole.budget_admin?
    # 予算担当　主管課
    @budget_main      = Gwsub::Sb06BudgetRole.budget_main?

    @menu_header3 = 'sb06_budget_assigns'
    @menu_title3  = '担当登録'

    # 所属選択　設定
    @group_id = nz(params[:group_id],0)
    # 兼務選択　設定
    @multi_group_id = nz(params[:multi_group_id],0)
    # 権限選択
    @b_role_id = nz(params[:b_role_id],0)

    # 主管課承認選択
    if @budget_main
      @m_state = nz(params[:m_state],2)
    else
      @m_state = nz(params[:m_state],0)
    end
    # 管理者承認選択
    if @budget_admin
      @a_state = nz(params[:a_state],2)
    else
      @a_state = nz(params[:a_state],0)
    end
    # 表示行数　設定
    @limit = nz(params[:limit],30)
    # 表示形式
    @v = nz(params[:v],'1')

    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current = '01'
    @l2_current = '01'
  end

  def search_condition
#    params[:fyed_id] = nz(params[:fyed_id],@fyed_id)
    params[:multi_group_id] = nz(params[:multi_group_id],@multi_group_id)
    params[:group_id]       = nz(params[:group_id],@group_id)
    params[:b_role_id]      = nz(params[:b_role_id],@b_role_id)
    params[:m_state]        = nz(params[:m_state],@m_state)
    params[:a_state]        = nz(params[:a_state],@a_state)
    params[:limit]          = nz(params[:limit], @limit)

    qsa = ['limit', 's_keyword' ,'multi_group_id','group_id','b_role_id','m_state','a_state' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'group_parent_code, budget_role_code, multi_user_code, multi_group_code')
#    @sort_keys = nz(params[:sort_keys], 'group_code , user_code')
  end

  def update_main_state
    # 主管課承認
    # 主管課なので、ログインユーザーが所属する所属の親に属するすべての課のみ対象
#     Gwsub::Sb06BudgetAssign.update_all( "main_state='1'" , "group_parent_id = #{Core.user_group.parent_id} and budget_role_code <> '1' " )
     Gwsub::Sb06BudgetAssign.where("group_parent_id = ? ",Core.user_group.parent_id).update_all( "main_state='1'")
  end
  def update_admin_state
    # 管理者承認
    # 管理者なので、すべての課が対象
     Gwsub::Sb06BudgetAssign.update_all( "admin_state='1'" )
  end

  def user_fields
    users = System::User.get_user_select(params[:g_id])
    render text: view_context.options_for_select(users), layout: false
  end

  def index_admin
    # 管理者はすべて
    item = Gwsub::Sb06BudgetAssign.new #.readable
    params.delete('group_parent_id') if params[:group_parent_id]
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
  end
  def index_main
    # 主管課は、同一上位の所属
    item = Gwsub::Sb06BudgetAssign.new #.readable
    item.search params
    item.and 'sql',"group_parent_id=#{Core.user_group.parent_id}"
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all )
#pp main_cond,@items
  end
  def index_normal
    # 一般は自所属のみ
    item = Gwsub::Sb06BudgetAssign.new #.readable
    params[:group_id] = Core.user_group.id
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
  end

end
