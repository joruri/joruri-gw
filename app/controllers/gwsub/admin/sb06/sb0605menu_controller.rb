class Gwsub::Admin::Sb06::Sb0605menuController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch

    return redirect_to(url_for(action: :index)) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "管理対象一覧"
  end

  #設定テーブルメンテナンス：対象テーブルの一覧をCms::Nodeから取得
  #ディレクトリ登録時に、このメニューと同じ階層にコントローラーを登録すること
  def index
    init_params
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
    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current = '03'
#    @l2_current = '01'  # コード管理の２階層目は、「一覧」固定
  end
  def search_condition
  end
  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'title ASC')
  end

end
