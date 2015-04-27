class Gw::Admin::ScheduleEventMastersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    Page.title = "週間・月間行事予定"
    @css = %w(/_common/themes/gw/css/prop_extra/schedule.css /_common/themes/gw/css/prop_extra/pm_rentcar.css)

    @is_admin = true # 管理者権限は後に設定する。
    @is_gw_admin = Gw.is_admin_admin? # GW全体の管理者
    @is_pm_admin = @is_gw_admin ? true : Gw::ScheduleProp.is_pm_admin? # 管財管理者

    @is_ev_admin = Gw::ScheduleEvent.is_ev_admin?
    @is_ev_management = Gw::ScheduleEventMaster.is_ev_management?
    @is_ev_operator = Gw::ScheduleEvent.is_ev_operator?
    return error_auth if !@is_gw_admin && !@is_ev_admin

    @model = Gw::ScheduleEventMaster
    @params_set = Gw::ScheduleEventMaster.params_set(params)
  end

  def index
    # 並び替え用
    @qsa = Gw.params_to_qsa(%w(s_m_gid s_d_gid), params)
    @qs = Gw.qsa_to_qs(@qsa)
    @sort_keys = CGI.unescape(nz(params[:sort_keys], ''))
    order = Gw.join([@sort_keys, "#{Gw.order_last_null "created_at", :order=>'desc'}"], ',')

    items = @model.where(func_name: 'gw_event', state: 'enabled')
    items = items.where(management_uid: Core.user.id) if @is_ev_management && !@is_ev_admin

    if params[:s_m_gid].to_i != 0
      if System::Group.find_by(id: params[:s_m_gid]).try(:level_no) == 2
        items = items.where(management_parent_gid: params[:s_m_gid])
      else
        items = items.where(management_gid: params[:s_m_gid])
      end
    end

    if params[:s_d_gid].to_i != 0
      if System::Group.find_by(id: params[:s_d_gid]).try(:level_no) == 2
        items = items.where(division_parent_gid: params[:s_d_gid])
      else
        items = items.where(division_gid: params[:s_d_gid])
      end
    end

    @items = items.order(order).paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @qsa = Gw.params_to_qsa(%w(s_m_gid s_d_gid sort_keys), params)
    @qs = Gw.qsa_to_qs(@qsa)
    @item = @model.find(params[:id])
  end

  def new
    @item = @model.new(range_class_id: 1, edit_auth: 1)
  end

  def create
    @item = @model.new(put_params(params, :create))

    _create @item, success_redirect_uri: url_for(action: :index) + @params_set, notice: '主管課ユーザーの登録に成功しました。'
  end

  def edit
    @item = @model.find(params[:id])
  end

  def update
    @item = @model.find(params[:id])
    @item.attributes = put_params(params, :update)

    _update @item, success_redirect_uri: url_for(action: :show, id: @item.id), notice: "主管課ユーザーの更新に成功しました。"
  end

  def destroy
    @item = @model.find(params[:id])
    @item.state       = 'deleted'
    @item.deleted_at  = Time.now
    @item.deleted_uid = Core.user.id
    @item.deleted_gid = Core.user_group.id
    @item.save(validate: false)

    flash[:notice] = "主管課担当者を削除しました。"
    @params_set.gsub!('&amp;', "&") # HTMLを通さないため、&amp;がそのままリンク先にされてしまう。そのため、置換しておく。

    redirect_to url_for(action: :index) + @params_set
  end

  private

  def put_params(_params, action)
    _params = _params[:item]

    if _params[:range_class_id] == "1"
      _params[:division_gid] = nil
    end

    management_g = System::Group.find_by(id: _params[:management_gid])
    _params = _params.merge(
      :management_parent_gid => management_g.try(:parent_id),
      :func_name => 'gw_event',
      :state => 'enabled'
    )
  end
end
