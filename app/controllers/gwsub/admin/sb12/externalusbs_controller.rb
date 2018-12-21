class Gwsub::Admin::Sb12::ExternalusbsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    return redirect_to(url_for(action: :index)) if params[:reset]
    section_name_select_list

    @usage_sql = 'ending_at IS NULL'
    params[:usage] = nz(params[:usage] , "u")
    params[:usage] = 's' if params[:sort].to_s == 'E'  #管理者[使用中止]リンク選択
    unless params[:usage].blank?
      @usage_sql = "" if params[:usage] == 'a'
      @usage_sql = "ending_at IS NOT NULL" if params[:usage] == 's'
    end
  end
  #初期値設定
  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Externalusb.is_dev?
    @role_sysadmin   = Gwsub::Externalusb.is_sysadmin?  #_admin
    @role_admin      = Gwsub::Externalusb.is_admin?
    @role_admin = @role_admin || @role_sysadmin
    @u_role = @role_developer || @role_admin

    @menu_header3 = 'externalusbs'
    Page.title = @menu_title3  = 'ＵＳＢ媒体管理'

    @cat    = nz(params[:cat],0)
    @limit = nz(params[:limit], 30)
    params[:limit]  = nz(params[:limit], @limit)

    sortkey_setting
    search_condition
    @css = %w(/_common/themes/gw/css/gwsub.css)
  end
  def search_condition
    if @role_admin
      qsa = ['sort','usage','scn','cat','s_keyword','limit']
    else
      qsa = ['sort','usage','cat','s_keyword','limit']
    end
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def sortkey_setting
    @l3_current='01'
    @t01_current='01'
    @t01_current='02' if params[:sort].to_s == 'e'
    @t01_current='03' if params[:sort].to_s == 'c'
    @t01_current='11' if params[:sort].to_s == 'A'
    @t01_current='12' if params[:sort].to_s == 'B'
    @t01_current='13' if params[:sort].to_s == 'C'
    @t01_current='14' if params[:sort].to_s == 'D'
    @t01_current='15' if params[:sort].to_s == 'E'
    @t01_current='16' if params[:sort].to_s == 'F'
    @sort_keys  = 'gwsub_externalusbs.section_name, '
    @sort_keys += 'gwsub_externalusbs.new_registedno' if @t01_current=='01'
    @sort_keys += 'gwsub_externalusbs.equipmentname, gwsub_externalusbs.new_registedno' if @t01_current=='02'
    @sort_keys += 'gwsub_externalusbs.registed_at, gwsub_externalusbs.new_registedno'   if @t01_current=='03'
    @sort_keys += 'gwsub_externalusbs.new_registedno'   if @t01_current=='11'
    @sort_keys += 'gwsub_externalusbs.equipmentname, gwsub_externalusbs.new_registedno'   if @t01_current=='12'
    @sort_keys += 'gwsub_externalusbs.registed_at, gwsub_externalusbs.new_registedno'   if @t01_current=='13'
    @sort_keys  = 'gwsub_externalusbs.sendstate, gwsub_externalusbs.section_name, gwsub_externalusbs.new_registedno'   if @t01_current=='14'
    @sort_keys += 'gwsub_externalusbs.new_registedno'   if @t01_current=='15'
    @sort_keys  = 'gwsub_externalusbs.new_registedno'   if @t01_current=='16'
  end

  #sort01:所属,登録番号,登録日,製品名
  #sort02:所属,製品名,登録番号,登録日
  #sort03:所属,登録日,登録番号,製品名
  def index
    init_params
    sb12_group_update
    item = Gwsub::Externalusb.new
    item.and :section_id, Core.user_group.id unless @role_admin
    item.and "sql", @usage_sql unless @usage_sql.blank?
    item.search params
    item.page   params[:page], params[:limit]
    @items = item.find(:all, :include=>:group, :order=>@sort_keys )
    _index @items
  end

  def show
    init_params
    @item = Gwsub::Externalusb.find(params[:id])
    unless @role_admin
      return error_auth unless @item.section_id == Core.user_group.id #管理者以外は、自所属以外の詳細閲覧は不可
    end
    _show @item
  end

  def new
    init_params
    return error_auth unless @u_role
    @l3_current='02'
    section_id = nz(params[:scn],Core.user_group.id)
    @item = Gwsub::Externalusb.new({
#        :section_id => Core.user_group.id ,
        :section_id => section_id ,
        :user_section_id => Core.user_group.id ,
        :registed_at => Gw.date_str(Core.now) ,
        :categories => 999 ,
        :sendstate =>  "none"
      })
    @item._is_new = true
    @item.new_registedno_setting
  end
  def create
    init_params
    return error_auth unless @u_role
    @l3_current='02'
    @item = Gwsub::Externalusb.new(usb_params)
    @item._is_new = true
    location = url_for(action: :index)
    _inherit_qs_s = @qs ? "?#{@qs}" : ''
    location = "#{location}#{_inherit_qs_s}"
    _create(@item,:success_redirect_uri=>location)
  end

  def edit
    init_params
    @item = Gwsub::Externalusb.find(params[:id])
    unless @role_admin
      return error_auth unless @item.section_id == Core.user_group.id #管理者以外は、自所属以外の詳細閲覧は不可
    end
    @section_name = ''
    @item.section_id = 0 if @item.section_id.blank?
    @section_name = @item.section_name if @item.section_id == 0
    @user_name = ''
    @user_name = @item.user if @item.user_id.blank?
    @item.registed_at = @item.registed_at.strftime('%Y-%m-%d')
    @item.ending_at = @item.ending_at.strftime('%Y-%m-%d') unless @item.ending_at.blank?
  end
  def update
    init_params
    @item = Gwsub::Externalusb.new.find(params[:id])
    unless @role_admin
      return error_auth unless @item.section_id == Core.user_group.id #管理者以外は、自所属以外の詳細閲覧は不可
    end
    @section_name = ''
    @item.section_id = 0 if @item.section_id.blank?
    @section_name = @item.section_name if @item.section_id == 0
    @user_name = ''
    @user_name = @item.user if @item.user_id.blank?
    @item.attributes = usb_params
    @item.section_id = 0 if @item.section_id.blank?
    location = url_for(action: :index)
    _inherit_qs_s = @qs ? "?#{@qs}" : ''
    location = "#{location}#{_inherit_qs_s}"
    _update(@item,:success_redirect_uri=>location)
  end

  def destroy
    init_params
    @item = Gwsub::Externalusb.find(params[:id])
    unless @role_admin
      return error_auth unless @item.section_id == Core.user_group.id #管理者以外は、自所属以外の詳細閲覧は不可
    end
    location = url_for(action: :index)
    _inherit_qs_s = @qs ? "?#{@qs}" : ''
    location = "#{location}#{_inherit_qs_s}"
    _destroy(@item,:success_redirect_uri=>location)
  end


  #所属によるユーザリスト作成
  def user_fields
    users = []
    users << ['指定なし', -1] if params[:sp] == 'y'
    users += System::User.get_user_select(params[:g_id], nil, ldap: 1)
    render text: view_context.options_for_select(users), layout: false
  end

  #
  def sb12_group_update
    chk = Gwsub::Sb12Group.first
    return if 1.hour.ago < chk.latest_updated_at  unless chk.blank?
    sql = 'SELECT section_id FROM gwsub_externalusbs GROUP BY section_id;'
    items = Gwsub::Externalusb.find_by_sql(sql)
    for item in items
      grp_id = item.section_id
      grp = System::Group.find_by(id: grp_id)
      if grp.blank?
        state = 'disabled'
        code = ''
        name = ''
        sort_no = 0
      else
        state = grp.state
        code = grp.code
        name = grp.name
        sort_no = grp.sort_no
      end
      latest_updated_at = Time.now
      #
      sb12 = Gwsub::Sb12Group.find_by(id: grp_id)
      if sb12.blank?
        sb12 = Gwsub::Sb12Group.new
        sb12.id = grp_id
      end
      sb12.state = state
      sb12.code = code
      sb12.name = name
      sb12.sort_no = sort_no
      sb12.latest_updated_at = latest_updated_at
      sb12.save
    end
  end

  def section_name_select_list
    sort_keys  = 'gwsub_sb12_groups.sort_no, gwsub_externalusbs.section_code, '
    sort_keys += 'gwsub_externalusbs.id'
    item = Gwsub::Externalusb.new
#    items = item.find(:all ,:select=>'gwsub_externalusbs.section_name', :include=>'group', :order=>sort_keys, :group => "gwsub_externalusbs.section_name" )
#    @sections = items.sort{|a,b| a.section_name<=>b.section_name}.map{|u| [u.section_name, u.section_name]}
    cond = "gwsub_sb12_groups.state='enabled'"
    items = item.find(:all ,:select=>'gwsub_externalusbs.section_name,gwsub_externalusbs.section_id', :include=>'group', :order=>sort_keys, :group => "gwsub_externalusbs.section_id" ,:conditions=>cond)
    @sections = items.sort{|a,b| a.section_name<=>b.section_name}.map{|u| [u.section_name, u.section_id]}

  end

  # 管理者
  def admin_index
    init_params
    return error_auth unless @u_role
    sb12_group_update
    item = Gwsub::Externalusb.new
    item.and "sql", @usage_sql unless @usage_sql.blank?
    item.search params
    item.page   params[:page], params[:limit]
    @items = item.find(:all, :include=>'group', :order => @sort_keys)
    _index @items
  end

  def csvput
    init_params
    return error_auth unless @u_role
    @l3_current='03'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = Gwsub::Externalusb.order(:id).to_csv(i18n_key: :default)
    send_data @item.encode(csv), filename: "sb12_external_usbs_#{@item.encoding}.csv"
  end

  def csvup
    init_params
    return error_auth unless @u_role
    @l3_current='04'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    Gwsub::Externalusb.transaction do
      Gwsub::Externalusb.truncate_table
      items = Gwsub::Externalusb.from_csv(@item.file_data, i18n_key: :default)
      items.each {|item| item.save(validate: false) }
    end

    flash[:notice] = '登録処理が完了しました。'
    redirect_to url_for(action: :index)
  end

private

  def usb_params
    params.require(:item).permit(:sendstate, :section_id, :new_registedno, :registedno, :externalmediakind_id,
      :registed_at, :equipmentname, :capacity, :capacityunit_id,
      :user_id, :user, :categories, :ending_at, :remarks)
  end

end
