class Gw::Admin::PropExtraGroupRentcarMastersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  def pre_dispatch

  end

  def init_params
    Page.title = "レンタカー所属別実績一覧 主管課マスタ"
    @is_admin = true # 管理者権限は後に設定する。
    @is_gw_admin = Gw.is_admin_admin? # GW全体の管理者
    @is_pm_admin = @is_gw_admin ? true : Gw::ScheduleProp.is_pm_admin? # 管財管理者
    @model = Gw::SectionAdminMaster
    @sp_mode = :schedule

    @erb_base = '/gw/public/prop_genre_common'
    @css = %w(/_common/themes/gw/css/prop_extra/schedule.css /_common/themes/gw/css/prop_extra/pm_rentcar.css)

    @user = Core.user
    @group = Core.user_group
    @gid = Core.user_group.id

    @params_set = Gw::PropExtraGroupRentcarMaster.params_set(params)
    @u_role = @is_pm_admin || @is_gw_admin
    @public_uri = %Q(#{url_for({:action=>:index})}/)

    # ヘッダ表示用
    @genre = 'rentcar'
    @sp_mode = :prop
    @cls = 'pm'
    @prop_extra_group_rentcar_masters = @genre
    @hedder2lnk = 3
    @hedder3lnk = 5
    @uri_base_prop_extras = "/gw/prop_extras"
  end

  def index
    init_params
    return error_auth unless @u_role == true
    @title_line = "主管課マスタ"

    cond = "func_name = 'gw_props' and state = 'enabled'"
    @s_m_gid = nz(params['s_m_gid'], "0").to_i  # System::Group.findでは、数値型しか受け入れられないのでto_iとする。
    if @s_m_gid != 0
      cond += " and " unless cond.blank?
      if System::Group.find(@s_m_gid).level_no == 2 # 部局か課か判定する
        cond += "management_parent_gid = #{@s_m_gid}"
      else
        cond += "management_gid = #{@s_m_gid}"
      end
    end

    @s_d_gid = nz(params['s_d_gid'], "0").to_i  # System::Group.findでは、数値型しか受け入れられないのでto_iとする。
    if @s_d_gid != 0
      cond += " and " unless cond.blank?
      if System::Group.find(@s_d_gid).level_no == 2 # 部局か課か判定する
        cond += "division_parent_gid = #{@s_d_gid}"
      else
        cond += "division_gid = #{@s_d_gid}"
      end
    end
    # 並び替え用
    @qsa = Gw.params_to_qsa(%w(s_m_gid s_d_gid), params)
    @qs = Gw.qsa_to_qs(@qsa)
    @sort_keys = CGI.unescape(nz(params[:sort_keys], ''))
    order = Gw.join([@sort_keys, "#{Gw.order_last_null "created_at", :order=>'desc'}"], ',')

    @items = @model.where(cond).order(order)
      .paginate(page: params[:page], per_page: params[:limit])
      .preload(:r_dept1, :r_sect1, :r_user, :r_dept2, :r_sect2)
  end

  def show
    init_params
    return error_auth unless @u_role == true
    @qsa = Gw.params_to_qsa(%w(s_m_gid s_d_gid sort_keys), params)
    @qs = Gw.qsa_to_qs(@qsa)
    @item = @model.find(params[:id])
    @title_line = "詳細"
  end

  def new
    init_params
    return error_auth unless @u_role == true
    @title_line = "新規作成"
    @item = @model.new({})
  end

  def edit
    init_params
    return error_auth unless @u_role == true
    @item = @model.find(params[:id])
    @title_line = "編集"
  end

  def create
    init_params
    return error_auth unless @u_role == true
    @title_line = "新規作成"
    _params = put_params(params, :create)
    @item = @model.new(_params)

    if Gw::PropExtraGroupRentcarMaster.find_uniqueness(_params, :create, nil, @model)  # 重複チェック
      _create @item, :success_redirect_uri => @public_uri + @params_set, :notice => '主管課ユーザーの登録に成功しました。'
    else
      @item.errors.add("この主管課担当者", "と、主管課担当範囲の組み合わせは、既に登録されています。")
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end

  end

  def update
    init_params
    return error_auth unless @u_role == true
    id = params[:id]
    @title_line = "編集"
    @item = @model.find(id)
    _params = put_params(params, :update)
    @item.attributes = _params

    if Gw::PropExtraGroupRentcarMaster.find_uniqueness(_params, :update, id, @model)  # 重複チェック
      _update @item, :success_redirect_uri => "#{@public_uri}#{id}#{@params_set}", :notice => "主管課ユーザーの更新に成功しました。"
    else
      @item.errors.add("この主管課担当者", "と、主管課担当範囲の組み合わせは、既に登録されています。")
      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end

  end

  def destroy
    init_params
    return error_auth unless @u_role == true
    @item = @model.find(params[:id])
    @item.state          = 'deleted'
    @item.deleted_at     = Time.now
    @item.deleted_uid    = @user.id
    @item.deleted_gid    = @gid
    @item.save(:validate => false)
    flash[:notice] = "主管課担当者を削除しました。"
    @params_set.gsub!('&amp;', "&") # HTMLを通さないため、&amp;がそのままリンク先にされてしまう。そのため、置換しておく。
    location = @public_uri + @params_set
    redirect_to location
  end

  def put_params(_params, action)
    _params = _params[:item]
    u = Core.user
    g = u.groups[0]
    management_g = Gw::Model::Schedule.get_group({:gid => _params[:management_gid]})
    if _params[:range_class_id] == "1"
      _params[:division_gid] = nil
    end

    _params = _params.merge({
      :management_parent_gid => management_g.parent_id,
      :func_name => 'gw_props',
      :state => 'enabled'
    })

    return _params
  end
end
