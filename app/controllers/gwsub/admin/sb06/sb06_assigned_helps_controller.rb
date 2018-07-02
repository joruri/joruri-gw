class Gwsub::Admin::Sb06::Sb06AssignedHelpsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch

    return redirect_to(url_for(action: :index)) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "担当者名等説明"
    init_params
    return error_auth unless @help_role == true
  end

  def index

    item = Gwsub::Sb06AssignedHelp.new #.readable
#    item.search params
#    item.creator
    case @help
    when 'admin'
      # 全体の操作説明等
      item.help_kind      = '1'
    else
      # 各申請書単位の説明
      item.help_kind      = '2'
      item.conf_kind_id   = @kind_id
      item.conf_cat_id    = @c_cat_id
    end
    item.page   params[:page], params[:limit]
    item.order @sort_keys, 'id ASC'
    @items = item.find(:all)
    _index @items
  end

  def show

    @item = Gwsub::Sb06AssignedHelp.find(params[:id])
  end

  def new

    @l4_current = '02'
    @item = Gwsub::Sb06AssignedHelp.new
    case @help
    when 'main_admin'
      @item.help_kind = 2
      @item.conf_cat_id = @c_cat_id
      @item.fyear_id    = @fy_id
    when 'admin'
      @item.help_kind = 1
    else
      @item.help_kind = 1
    end
  end
  def create

    @l4_current = '02'
    @item = Gwsub::Sb06AssignedHelp.new(params[:item])
    case @help
    when 'admin'
      param = "?help=#{@help}&pre_fy_id=#{@fy_id}&fy_id=#{@fy_id}"
    when 'main_admin'
      param = "?help=#{@help}&pre_fy_id=#{@fy_id}&fy_id=#{@fy_id}&pre_c_cat_id=#{@c_cat_id}&c_cat_id=#{@c_cat_id}&kind_id=#{@kind_id}"
    else
      param = "?help=#{@help}&pre_fy_id=#{@fy_id}&fy_id=#{@fy_id}&pre_c_cat_id=#{@c_cat_id}&c_cat_id=#{@c_cat_id}&kind_id=#{@kind_id}"
    end
    location =  "/gwsub/sb06/sb06_assigned_helps#{param}"
    options = {
      :success_redirect_uri=>location,
    }
    _create(@item,options)
  end

  def edit

    @item = Gwsub::Sb06AssignedHelp.find(params[:id])
  end
  def update

    @item = Gwsub::Sb06AssignedHelp.find(params[:id])
    @item.attributes = params[:item]
    case @help
    when 'admin'
      param = "?help=#{@help}&pre_fy_id=#{@fy_id}&fy_id=#{@fy_id}"
    when 'main_admin'
      param = "?help=#{@help}&pre_fy_id=#{@fy_id}&fy_id=#{@fy_id}&pre_c_cat_id=#{@c_cat_id}&c_cat_id=#{@c_cat_id}&kind_id=#{@kind_id}"
    else
      param = "?help=#{@help}&pre_fy_id=#{@fy_id}&fy_id=#{@fy_id}&pre_c_cat_id=#{@c_cat_id}&c_cat_id=#{@c_cat_id}&kind_id=#{@kind_id}"
    end
    location =  "/gwsub/sb06/sb06_assigned_helps/#{@item.id}#{param}"
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

  def destroy

    @item = Gwsub::Sb06AssignedHelp.find(params[:id])
    case @help
    when 'admin'
      param = "?help=#{@help}&pre_fy_id=#{@fy_id}&fy_id=#{@fy_id}"
    when 'main_admin'
      param = "?help=#{@help}&pre_fy_id=#{@fy_id}&fy_id=#{@fy_id}&pre_c_cat_id=#{@c_cat_id}&c_cat_id=#{@c_cat_id}&kind_id=#{@kind_id}"
    else
      param = "?help=#{@help}&pre_fy_id=#{@fy_id}&fy_id=#{@fy_id}&pre_c_cat_id=#{@c_cat_id}&c_cat_id=#{@c_cat_id}&kind_id=#{@kind_id}"
    end
    location =  "/gwsub/sb06/sb06_assigned_helps#{param}"
    options = {
      :success_redirect_uri=>location,
    }
    _destroy(@item,options)
  end

  def init_params
#pp params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb06AssignedConference.is_dev?
    @role_admin      = Gwsub::Sb06AssignedConference.is_admin?
    @role_main_group = false

    @role_editor     = Core.user_group.code
    # 表示モード (show(一般)/main_admin(主管課)/admin(管理者))
    @help = nz(params[:help],"main_admin")
    # 一覧表示選択条件を、メニュー選択と検索UIで合わせる（初期値での年度、主管所属、申請書種別「すべて」を抑止）
    # 年度
    fy_group    = "fyear_markjp"
    fy_order    = "fyear_markjp DESC , group_code ASC"
    fyear       = Gw::YearFiscalJp.get_record(Time.now)
    fy_id       = fyear.blank? ? 0 : fyear.id
    @fy_id      = nz(params[:fy_id],fy_id)

    # 申請書分類
    # 初期値は「すべて」
    @c_cat_id = nz(params[:c_cat_id],0)

    # 申請書種別
    @kind_id      = nz(params[:kind_id],0)
    # 申請書指定時は、分類逆引き
    if @kind_id.to_i==0
      conf_kind_options = {:cat_id=>@c_cat_id}
      conf_kinds    = Gwsub::Sb06AssignedConfKind.sb06_assign_conf_kind_id_select(conf_kind_options)
      if conf_kinds.blank?
        @kind_id      = nz(params[:kind_id],0)
      else
        kind_id       = conf_kinds[0]
        @kind_id      = nz(params[:kind_id],0)          if      @c_cat_id.to_i==0
        @kind_id      = nz(params[:kind_id],kind_id[1]) unless  @c_cat_id.to_i==0
      end
    else
      conf_kind   =  Gwsub::Sb06AssignedConfKind.find(@kind_id)
      conf_cat    = Gwsub::Sb06AssignedConfCategory.find(conf_kind.conf_cat_id)
      conf_cat.c_grp.each do |grp|
        @role_main_group = true if grp.group_code = Core.user_group.code
      end if @help == "main_admin"
      @c_cat_id   = conf_cat.id unless conf_cat.blank?
    end

    # 主管所属
    @c_group_id     = nz(params[:c_group_id],0)
    # 表示行数　設定
    @limit = nz(params[:limit],30)


    params[:help] = @help
    # 表示対象 help_kind)
    case @help
    when 'admin'
      @help_kind           = 1
      params[:help_kind]  = 1
      params[:kind_id]    = 0
      params[:c_cat_id]   = 0
      @kind                = 0
      @c_cat_id            = 0
    when 'main_admin'
      @help_kind  = 2
      params[:help_kind]  = 2
    else
      @help_kind  = 2
      params[:help_kind]  = 2
    end

    # メニュー見出し
    @menu_header3 = 'sb06_assigned_helps'
    @menu_title3  = '操作説明等管理'
    @menu_title3  = '説明管理'       if @help=='main_admin'

    search_condition
    setting_sortkeys
    @css = %w(/_common/themes/gw/css/gwsub.css)
    if @help=='main_admin'
      @l1_current = '01'
      @l2_current = @c_cat_id
      @l4_current = '01'
    else
      @l1_current = '03'
      @l4_current = '01'
    end
    @u_role = @role_developer || @role_admin
    @help_role = @role_developer || @role_admin || @role_main_group
    return
  end
  def search_condition
    params[:limit]        = nz(params[:limit], @limit)
    params[:fy_id]        = nz(params[:fy_id],@fy_id)
    params[:c_cat_id]     = nz(params[:c_cat_id],@c_cat_id)
    params[:kind_id]      = nz(params[:kind_id],@kind_id)
    params[:c_group_id]   = nz(params[:c_group_id],@c_group_id)

    qsa = ['limit', 's_keyword','help_kind','c_cat_id','kind_id','fy_id','c_group_id' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sortkeys
    @sort_keys = nz(params[:sort_keys], "help_kind , conf_kind_sort_no, sort_no, title")
  end

  def kind_fields
    kinds = Gwsub::Gwsub::Sb06AssignedConfKind.sb06_assign_conf_kind_id_select(cat_id: params[:c_cat_id].to_i)
    render text: view_context.options_for_select(kinds), layout: false
  end
end
