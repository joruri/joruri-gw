class Gwsub::Admin::Sb06::Sb06BudgetAssignCsvputController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch

    return redirect_to(url_for(action: :index)) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "予算担当CSV出力"
  end

  def index
    init_params

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    if @item.extras[:name].blank?
      @item.errors.add(:base, "ファイル名を入力してください。")
      return
    end

    target_columns = [:multi_group_code, :multi_user_code, :user_name, :budget_role_code]
    csv = Gwsub::Sb06BudgetAssign.select(target_columns)
      .order(:multi_user_code, :multi_group_code, :budget_role_code)
      .to_csv(only: target_columns, headers: false)

    send_data @item.encode(csv), filename: "#{@item.extras[:name]}.csv"
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
    @budget_main      = Gwsub::Sb06BudgetRole.budget_admin?

    @menu_header3 = 'sb06_budget_assign_csvput'
    @menu_title3  = 'CSV出力'

    # 年度選択　設定
      # 年度変更時は、所属選択をクリア
    if params[:fyed_id]
      if params[:pre_fyear] != params[:fyed_id]
        params[:grped_id] = 0
      end
    else
        params[:grped_id] = 0
    end
    # 年度選択　設定
    @fyed_id = Gwsub.set_fyear_select(params[:fyed_id],'init')
    # 所属選択　設定
    @grped_id = Gwsub.set_section_select(@fyed_id , params[:grped_id])
    # 表示行数　設定
    @limits = nz(params[:limit],30)
    # 表示形式
    @v = nz(params[:v],'1')

    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current ='03'
    @l2_current ='04'
  end

  def search_condition
    params[:fyed_id] = nz(params[:fyed_id],@fyed_id)
    params[:grped_id] = nz(params[:grped_id],@grped_id)
    params[:limit] = nz(params[:limit], @limits)

    qsa = ['limit', 's_keyword' ,'fyed_id','grped_id' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'fyear_id ASC , group_code')
  end

end
