class Gwsub::Admin::Sb06::Sb06AssignedConfKindsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    return redirect_to(url_for(action: :index)) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "30申請書種別"
    init_params
    return error_auth unless @u_role == true
  end

  def index

    return error_auth unless @u_role==true
#    pp params
    item = Gwsub::Sb06AssignedConfKind.new
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:sort_keys], @sort_keys
    @items = item.find(:all)
    _index @items
  end
  def show

    return error_auth unless @u_role==true

    @item = Gwsub::Sb06AssignedConfKind.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
  end

  def new

    return error_auth unless @u_role==true

    @l3_current='02'
    @item = Gwsub::Sb06AssignedConfKind.new
    @item.select_list=1
  end
  def create

    return error_auth unless @u_role==true

    @l3_current='02'
    @item = Gwsub::Sb06AssignedConfKind.new(params[:item])
    location = "#{url_for({:action => :index})}?#{@qs}"
    _create(@item,:success_redirect_uri=>location)
  end

  def edit

    return error_auth unless @u_role==true

    @item = Gwsub::Sb06AssignedConfKind.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    @cat_id = @item.conf_cat_id
    @fyear_id = @item.fyear_id
  end
  def update

    return error_auth unless @u_role==true

    @item = Gwsub::Sb06AssignedConfKind.where(:id => params[:id]).first
    return http_error(404) if @item.blank?

    @item.attributes = params[:item]
    location = "#{url_for({:action => :index})}?#{@qs}"
    _update(@item,:success_redirect_uri=>location)
  end

  def destroy

    return error_auth unless @u_role==true

    @item = Gwsub::Sb06AssignedConfKind.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
    location = "#{url_for({:action => :index})}?#{@qs}"
    _destroy(@item,:success_redirect_uri=>location)
  end

  def csvput
    return error_auth unless @u_role==true

    @l3_current='03'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = Gwsub::Sb06AssignedConfKind.all.to_csv(i18n_key: :default)
    send_data @item.encode(csv), filename: "sb06_assigned_conf_kinds_#{@item.encoding}.csv"
  end

  def csvup
    return error_auth unless @u_role==true

    @l3_current='04'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    Gwsub::Sb06AssignedConfKind.transaction do
      Gwsub::Sb06AssignedConfKind.truncate_table
      items = Gwsub::Sb06AssignedConfKind.from_csv(@item.file_data, i18n_key: :default)
      items.each(&:save)
    end

    flash[:notice] = '登録処理が完了しました。'
    redirect_to action: :index
  end

  def init_params
    require 'cgi'
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb06AssignedConference.is_dev?
    @role_admin      = Gwsub::Sb06AssignedConference.is_admin?
    @u_role = @role_developer || @role_admin
    @role_editor     = Core.user_group.code

    @menu_header3 = 'sb0606menu'
    @menu_title3  = 'コード管理'
    @menu_header4 = 'sb06_assigned_conf_kinds'
    @menu_title4  = '申請書種別'

    # 年度設定
    @fyear_id = nz(params[:fyear_id],0)
    # 分類設定
    @cat_id   = nz(params[:cat_id],0)
    # 表示行数　設定
    @limit    = nz(params[:limit],30)
    # 検索文字列
#pp params
    if params[:s_keyword]
#      if request.env['HTTP_USER_AGENT'] =~ /MSIE/
#        @s_keyword = params[:s_keyword]
#      else
        @s_keyword = CGI.escape(params[:s_keyword])
#      end
    else
      @s_keyword = nil
    end
pp @s_keyword

    search_condition
    setting_sortkeys
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current='04'
    @l2_current='01'
    @l3_current='01'

    return
  end
  def search_condition
    params[:fyear_id]   = nz(params[:fyear_id], @fyear_id)
    params[:cat_id]     = nz(params[:cat_id], @cat_id)
    params[:limit]      = nz(params[:limit], @limit)
    params[:s_keyword]  = nz(params[:s_keyword], @s_keyword)

    qsa = ['limit', 's_keyword' ,'fyear_id','cat_id']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
pp @qs
  end
  def setting_sortkeys
    @sort_keys = nz(params[:sort_keys], 'fyear_markjp desc , conf_kind_sort_no ASC')
  end

end
