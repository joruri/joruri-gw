# -*- encoding: utf-8 -*-
class Gwsub::Admin::Sb04::Sb04stafflistviewMastersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  layout "admin/template/portal_1column"

  def initialize_scaffold
    @page_title = "電子職員録 主管課マスタ"
  end

  def init_params

    @is_admin = true # 管理者権限は後に設定する。
    @is_gw_admin = Gw.is_admin_admin? # GW全体の管理者
    @model = Gw::SectionAdminMaster
    @css = %w(/_common/themes/gw/css/gwsub.css)

    @user = Core.user
    @group = Core.user_group
    @gid = Core.user_group.id

    @role_developer  = Gwsub::Sb04stafflist.is_dev?(Core.user.id)
    @role_admin      = Gwsub::Sb04stafflist.is_admin?(Core.user.id)
    @u_role = @role_developer || @role_admin

    @menu_header3 = 'sb04stafflistview_masters'
    @menu_title3  = '職員録'
    @menu_header4 = 'sb04stafflistview_masters'
    @menu_title4  = '主管課マスタ'
    @l1_current = '06'

    @params_set = Gwsub::Sb04stafflistviewMaster.params_set(params)

    @public_uri = "/gwsub/sb04/01/sb04stafflistview_masters"

    @fyed_id = Gwsub.set_fyear_select(params[:fyed_id],{:role=>@u_role})
    @section = Gwsub::Sb04section.new.find(:first, :conditions=>["fyear_id = ?", @fyed_id], :select=>"id")
    @section_id = !@section.blank? ? @section.id : 1
  end

  def index
    init_params
    return authentication_error(403) unless @u_role == true
    @l2_current = '01'
    item = @model.new
    item.page  params[:page], params[:limit]

    if params[:s_old_f_id].blank?
      @s_old_f_id = @fyed_id
    else
      @s_old_f_id = params[:s_old_f_id].to_i
    end

    cond = "func_name = 'gwsub_sb04' and state = 'enabled'"

    @s_f_id = nz(params[:s_f_id], "0").to_i
    if @s_f_id != 0
      cond += " and " unless cond.blank?
      cond += "fyear_id_sb04 = #{@s_f_id}"
      if @s_old_f_id != @s_f_id
        params[:s_m_gid] = '0'
        params[:s_d_gid] = '0'
        @s_old_f_id = @s_f_id
      end
    end

    @s_m_gid = nz(params[:s_m_gid], "0").to_i
    if @s_m_gid != 0
      cond += " and " unless cond.blank?
      cond += "management_gid_sb04 = #{@s_m_gid}"
    end

    @s_d_gid = nz(params[:s_d_gid], "0").to_i
    if @s_d_gid != 0
      cond += " and " unless cond.blank?
      cond += "division_gid_sb04 = #{@s_d_gid}"
    end

    # 並び替え用
    @qsa = Gw.params_to_qsa(%w(s_m_gid s_d_gid s_f_id s_old_f_id), params)
    @qs = Gw.qsa_to_qs(@qsa,{:no_entity=>true})
    @sort_keys = CGI.unescape(nz(params[:sort_keys], ''))
    order = Gw.join([@sort_keys, "fyear_id_sb04 DESC", "management_gcode", "management_ucode"], ',')

    @items = item.find(:all, :conditions => cond, :order => order)
  end

  def show
    init_params
    return authentication_error(403) unless @u_role == true
    @qsa = Gw.params_to_qsa(%w(s_m_gid s_d_gid sort_keys), params)
    @qs = Gw.qsa_to_qs(@qsa,{:no_entity=>true})
    @item = @model.find_by_id(params[:id])
    return http_error(404) if @item.blank?
  end

  def new
    init_params
    return authentication_error(403) unless @u_role == true
    @l2_current = '02'

    @item = @model.new({})
  end

  def edit
    init_params
    return authentication_error(403) unless @u_role == true

    @item = @model.find_by_id(params[:id])
    return http_error(404) if @item.blank?
  end

  def create
    init_params
    return authentication_error(403) unless @u_role == true

    _params = put_params(params, :create)
    @item = @model.new(_params)

    if _params[:management_uid_sb04].present? && Gwsub::Sb04stafflistviewMaster.find_uniqueness(_params, :create, nil, @model)  # 重複チェック
      _create(@item, {:location => "#{@public_uri}#{@params_set}", :notice => '主管課ユーザーの登録に成功しました。'} )
    else
      if _params[:management_uid_sb04].blank?
        @item.errors.add("主管課担当者", "を選択してください。")
      else
        @item.errors.add("この主管課担当者", "と、主管課担当範囲の組み合わせは、既に登録されています。")
      end

      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end

  end

  def update
    init_params
    return authentication_error(403) unless @u_role == true
    id = params[:id]
    @item = @model.find_by_id(id)
    return http_error(404) if @item.blank?

    _params = put_params(params, :update)
    @item.attributes = _params

    if _params[:management_uid_sb04].present? && Gwsub::Sb04stafflistviewMaster.find_uniqueness(_params, :update, id, @model)  # 重複チェック
      _update @item, :location => "#{@public_uri}#{id}#{@params_set}", :notice => "主管課ユーザーの更新に成功しました。"
    else
      if _params[:management_uid_sb04].blank?
        @item.errors.add("主管課担当者", "を選択してください。")
      else
        @item.errors.add("この主管課担当者", "と、主管課担当範囲の組み合わせは、既に登録されています。")
      end
      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end

  end

  def destroy
    init_params
    return authentication_error(403) unless @u_role == true
    @item = @model.find_by_id(params[:id])
    return http_error(404) if @item.blank?

    @item.state          = 'deleted'
    @item.deleted_at     = Time.now
    @item.deleted_uid    = @user.id
    @item.deleted_gid    = @gid
    @item.save(:validate=>false)
    flash[:notice] = "主管課担当割当を削除しました。"
    location = @public_uri + @params_set
    redirect_to location
    return

  end

  def section_fields_year_copy
    init_params
    fyed_id = nz(params[:fyed_id], @fyed_id)
    if @u_role == true
      sections = Gwsub::Sb04section.sb04_group_select(fyed_id, 1)
    else
      sections = Gwsub::Sb04stafflistviewMaster.sb04_dev_group_select(fyed_id.to_i)
    end
    _html_select = ''
    if sections.blank?
        _html_select << "<option value='0'>所属未設定</option>"
    else
      sections.each do |value , key|
        _html_select << "<option value='#{key}'>#{value}</option>"
      end
    end
    respond_to do |format|
      format.csv { render :text => _html_select ,:layout=>false ,:locals=>{:f=>@item} }
    end
  end

  def put_params(_params, action)
    _params = _params[:item]

    if _params[:management_uid_sb04].present?
      staff = Gwsub::Sb04stafflist.find_by_id(_params[:management_uid_sb04])
      user = System::User.find_by_code(staff.staff_no)
      if user.present?
        _params = _params.merge({:management_uid => user.id})
        group = user.groups[0]
        _params = _params.merge({:management_gid => group.id})
        _params = _params.merge({:management_parent_gid => group.parent_id})
      else
        _params = _params.merge({:management_uid => nil, :management_gid => nil, :management_parent_gid => nil})
      end
      _params = _params.merge({:management_ucode => staff.staff_no})
    end
    if !_params[:management_gid_sb04].blank?
      section = Gwsub::Sb04section.find_by_id(_params[:management_gid_sb04])
      _params = _params.merge({ :management_gcode => section.code }) if section.present?
    end
    if !_params[:division_gid_sb04].blank?
      section = Gwsub::Sb04section.find_by_id(_params[:division_gid_sb04])
      _params = _params.merge({ :division_gcode => section.code }) if section.present?
    end
    _params = _params.merge({
      :func_name => 'gwsub_sb04',
      :range_class_id => 2,
    })

    return _params
  end

end
