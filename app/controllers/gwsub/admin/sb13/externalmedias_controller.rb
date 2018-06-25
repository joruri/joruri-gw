class Gwsub::Admin::Sb13::ExternalmediasController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    return redirect_to(url_for(action: :index)) if params[:reset]
    section_name_select_list

    @usage_sql = 'ending_at IS NULL'
    params[:usage] = nz(params[:usage] , "u")
    unless params[:usage].blank?
      @usage_sql = "" if params[:usage] == 'a'
      @usage_sql = "ending_at IS NOT NULL" if params[:usage] == 's'
    end
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Externalmedia.is_dev?
    @role_sysadmin   = Gwsub::Externalmedia.is_sysadmin? #_admin
    @role_admin      = Gwsub::Externalmedia.is_admin?
    @role_admin = @role_admin || @role_sysadmin
    @u_role = @role_developer || @role_admin

    @menu_header3 = 'externalmedias'
    Page.title = @menu_title3  = '外部媒体管理'

    @cat  = nz(params[:cat],0)
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
    @l3_current ='01'
    @t01_current='01'
    @t01_current='02' if params[:sort].to_s == 'e'
    @t01_current='03' if params[:sort].to_s == 'c'
    @t01_current='11' if params[:sort].to_s == 'A'
    @t01_current='12' if params[:sort].to_s == 'B'
    @t01_current='13' if params[:sort].to_s == 'C'
    @t01_current='14' if params[:sort].to_s == 'D'
    @t01_current='15' if params[:sort].to_s == 'E'
    @t01_current='16' if params[:sort].to_s == 'F'
    @sort_keys =  'gwsub_externalmedias.section_name, '
    @sort_keys += 'gwsub_externalmedias.new_registedno' if @t01_current=='01'
    @sort_keys += 'gwsub_externalmedias.equipmentname, gwsub_externalmedias.new_registedno' if @t01_current=='02'
    @sort_keys += 'gwsub_externalmedias.registed_at, gwsub_externalmedias.new_registedno'   if @t01_current=='03'
    @sort_keys += 'gwsub_externalmedias.new_registedno'   if @t01_current=='11'
    @sort_keys += 'gwsub_externalmedias.equipmentname, gwsub_externalmedias.new_registedno'   if @t01_current=='12'
    @sort_keys += 'gwsub_externalmedias.registed_at, gwsub_externalmedias.new_registedno'   if @t01_current=='13'
    @sort_keys  = 'gwsub_externalmedias.sendstate, gwsub_externalmedias.section_name, gwsub_externalmedias.new_registedno'   if @t01_current=='14'
    @sort_keys += 'gwsub_externalmedias.new_registedno'   if @t01_current=='15'
    @sort_keys  = 'gwsub_externalmedias.new_registedno'   if @t01_current=='16'
  end

  #sort01:所属,登録番号,登録日,媒体名
  #sort02:所属,媒体名,登録番号,登録日
  #sort03:所属,登録日,登録番号,媒体名
  def index
    init_params
    sb13_group_update
    item = Gwsub::Externalmedia.new
    item.and :section_id, Core.user_group.id unless @role_admin
    item.and "sql", @usage_sql unless @usage_sql.blank?
    item.search params
    item.page   params[:page], params[:limit]
    @items = item.find(:all, :include=>:group, :order=>@sort_keys )
    _index @items
  end

  def show
    init_params
    @item = Gwsub::Externalmedia.find(params[:id])
    unless @role_admin
      return error_auth unless @item.section_id == Core.user_group.id #管理者以外は、自所属以外の詳細閲覧は不可
    end
    _show @item
  end

  def new
    init_params
    @l3_current='02'
    section_id = nz(params[:scn],Core.user_group.id)
    @is_new = true
    @item = Gwsub::Externalmedia.new({
#        :section_id => Core.user_group.id ,
        :section_id => section_id ,
#        :section_name => Core.user_group.name ,
#        :section_name => System::Group.find_by_id(section_id).ou_name ,
        :section_name => Core.user_group.code.to_s + Core.user_group.name.to_s ,
        :user_section_id => Core.user_group.id ,
        :registed_at => Gw.date_str(Core.now),
        :registedno => '' ,
        :categories => 999
      })
    @item._is_new = true
    @item.new_registedno_setting
  end
  def create
    init_params
    @l3_current='02'
    @is_new = true
    @item = Gwsub::Externalmedia.new(params[:item])
    unless @role_admin
      @item.section_id = Core.user_group.id if @item.section_id.blank?
      @item.section_name = Core.user_group.name if @item.section_name.blank?
      @item.registedno = '' if @item.registedno.blank?
    end
    @item._is_new = true
    new_registedno = @item.new_registedno
    @item.new_registedno = '' unless @role_admin
    location = url_for(action: :index)
    _inherit_qs_s = @qs ? "?#{@qs}" : ''
    location = "#{location}#{_inherit_qs_s}"
    _create_sb13(@item,{:before_id=>new_registedno, :success_redirect_uri=>location})
  end

  def edit
    init_params
    @item = Gwsub::Externalmedia.find(params[:id])
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
    @item = Gwsub::Externalmedia.new.find(params[:id])
    unless @role_admin
      return error_auth unless @item.section_id == Core.user_group.id #管理者以外は、自所属以外の詳細閲覧は不可
    end
    @section_name = ''
    @item.section_id = 0 if @item.section_id.blank?
    @section_name = @item.section_name if @item.section_id == 0
    @user_name = ''
    @user_name = @item.user if @item.user_id.blank?
    @item.attributes = params[:item]
    @item.section_id = 0 if @item.section_id.blank?
    location = url_for(action: :index)
      _inherit_qs_s = @qs ? "?#{@qs}" : ''
      location = "#{location}#{_inherit_qs_s}"
    _update(@item,:success_redirect_uri=>location)
  end

  def destroy
    init_params
    @item = Gwsub::Externalmedia.find(params[:id])
    location = url_for(action: :index)
      _inherit_qs_s = @qs ? "?#{@qs}" : ''
      location = "#{location}#{_inherit_qs_s}"
    _destroy(@item,:success_redirect_uri=>location)
  end

  def user_fields
    users = []
    users << ['指定なし', -1] if params[:sp] == 'y'
    users += System::User.get_user_select(params[:g_id], nil, ldap: 1)
    render text: view_context.options_for_select(users), layout: false
  end

  def sb13_group_update
    chk = Gwsub::Sb13Group.first
    return if 1.hour.ago < chk.latest_updated_at  unless chk.blank?
    sql = 'SELECT section_id FROM gwsub_externalmedias GROUP BY section_id;'
    items = Gwsub::Externalmedia.find_by_sql(sql)
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
      state = 'disabled' if state.blank?
      sb13 = Gwsub::Sb13Group.find_by(id: grp_id)
      if sb13.blank?
        sb13 = Gwsub::Sb13Group.new
        sb13.id = grp_id
      end
      sb13.state = state
      sb13.code = code
      sb13.name = name
      sb13.sort_no = sort_no
      sb13.latest_updated_at = latest_updated_at
      sb13.save
    end
  end

  def section_name_select_list
    sort_keys =  'gwsub_sb13_groups.sort_no, gwsub_externalmedias.section_code, '
    sort_keys += 'gwsub_externalmedias.id'
    item = Gwsub::Externalmedia.new
#    items = item.find(:all ,:select=>'gwsub_externalmedias.section_name', :include=>'group', :order=>sort_keys, :group => "gwsub_externalmedias.section_name" )
#    @sections = items.sort{|a,b| a.section_name<=>b.section_name}.map{|u| [u.section_name, u.section_name]}
    cond = "gwsub_sb13_groups.state='enabled'"
    items = item.find(:all ,:select=>'gwsub_externalmedias.section_name,gwsub_externalmedias.section_id', :include=>'group', :order=>sort_keys, :group => "gwsub_externalmedias.section_name" ,:conditions=>cond)
    @sections = items.sort{|a,b| a.section_name<=>b.section_name}.map{|u| [u.section_name, u.section_id]}
  end

  # 管理者
  def admin_index
    init_params
    return error_auth unless @u_role
    sb13_group_update
    item = Gwsub::Externalmedia.new
    item.and "sql", @usage_sql unless @usage_sql.blank?
    item.search params
    item.page   params[:page], params[:limit]
    @items = item.find(:all, :include=>'group', :order => @sort_keys)
    _index @items
  end

  def csvput
    init_params
    @l3_current='03'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = Gwsub::Externalmedia.all.to_csv(i18n_key: :default)
    send_data @item.encode(csv), filename: "sb13_external_medias_#{@item.encoding}.csv"
  end

  def csvup
    init_params
    @l3_current='04'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    Gwsub::Externalmedia.transaction do
      Gwsub::Externalmedia.truncate_table
      items = Gwsub::Externalmedia.from_csv(@item.file_data, i18n_key: :default)
      items.each {|item| item.save(validate: false) }
    end

    flash[:notice] = '登録処理が完了しました。'
    redirect_to url_for(action: :index)
  end


  #新規更新時に管理番号変更されたらメッセージを表示する対応
  def _create_sb13(item, options = {})
    respond_to do |format|
      validation = nz(options[:validation], true)
      if item.creatable? && item.save(validate: validation)
        options[:after_process].call if options[:after_process]

        location = nz(options[:success_redirect_uri], url_for(:action => :index))
        location.sub!(/\[\[id\]\]/, "#{item.id}") if options[:no_update_id].nil?
        status = params[:_created_status] || :created
        flash[:notice] = options[:notice] || '登録処理が完了しました'
        flash[:notice] = "保存時に管理番号が重複したので、#{sprintf('%06d',item.new_registedno)} で登録しました。" unless options[:before_id].to_s == item.new_registedno.to_s unless options[:before_id].blank?
        format.html { redirect_to location }
        format.xml  { render :xml => to_xml(item), :status => status, :location => location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

end
