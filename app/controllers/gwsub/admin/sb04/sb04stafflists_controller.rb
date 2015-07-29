# -*- encoding: utf-8 -*-
class Gwsub::Admin::Sb04::Sb04stafflistsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  layout "admin/template/portal_1column"

  def initialize_scaffold
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    @page_title = "電子職員録 職員一覧"
  end

  def index
    init_params
    item = Gwsub::Sb04stafflist.new #.readable
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    if @role_sb04_dev
      gids = Gwsub::Sb04stafflistviewMaster.get_division_sb04_gids # ログインユーザーの主管課範囲のコード
      condition = Condition.new()
      condition.and do |cond|
        gids.each do |gid|
          cond.or 'section_id', '=', gid
        end
      end
      item.and condition
    end
    @items = item.find(:all)
    _index @items
  end

  def show
    init_params
    @item = Gwsub::Sb04stafflist.find_by_id(params[:id])
    return http_error(404) if @item.blank?
    _show @item
  end

  def new
    init_params
    @l3_current = '03'
    @item = Gwsub::Sb04stafflist.new({
        :multi_section_flg => 1,
        :personal_state => 1,
        :display_state => 1
      })
    if @fyed_id.to_i == 0
      @fyed_id = Gw::YearFiscalJp.get_record(Time.now).id
      editable_date = Gwsub::Sb04EditableDate.find(:first, :conditions=>"fyear_id = #{@fyed_id}")
      if editable_date.blank?
        editable_date = Gwsub::Sb04EditableDate.find(:first, :order=>"published_at desc")
        @fyed_id = editable_date.fyear_id if editable_date.present?
      end
    end
    if @u_role
      @grped_id = Gwsub.set_section_select(@fyed_id , @grped_id , nil)
    elsif @role_sb04_dev
      groups = Gwsub::Sb04stafflistviewMaster.sb04_dev_group_select(@fyed_id)
      if params[:item].blank?
        if groups.rassoc(@grped_id.to_i).blank?
          @grped_id = groups[0][1]
        end
      end
    end
    # 絞込条件の持ち回り
    set_param
  end
  def create
    init_params
    @item = Gwsub::Sb04stafflist.new(params[:item])
    location = "/gwsub/sb04/04/sb04stafflists?#{@qs}"

    if @item.stafflist_data_save(params, :create)
      flash_notice '登録', true
      redirect_to location
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end

  end

  def edit
    init_params
    @item = Gwsub::Sb04stafflist.find_by_id(params[:id])
    return http_error(404) if @item.blank?

    @fyed_id = @item.fyear_id
    @grped_id = @item.section_id
    # 絞込条件の持ち回り
    set_param
  end
  def update
    init_params
    @item = Gwsub::Sb04stafflist.find_by_id(params[:id])
    return http_error(404) if @item.blank?

    @item.attributes = params[:item]
    location = "/gwsub/sb04/04/sb04stafflists/#{@item.id}?#{@qs}"

    if @item.stafflist_data_save(params, :update)
      flash_notice '更新', true
      redirect_to location
    else
      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    init_params
    @item = Gwsub::Sb04stafflist.find(params[:id])
    return http_error(404) if @item.blank?
    location = "/gwsub/sb04/04/sb04stafflists?#{@qs}"
    options = {:location=>location}
    _destroy(@item,options)
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb04stafflist.is_dev?(Site.user.id)
    @role_admin      = Gwsub::Sb04stafflist.is_admin?(Site.user.id)
    @u_role = @role_developer || @role_admin

    # 電子職員録 主管課権限設定
    @role_sb04_dev  = Gwsub::Sb04stafflistviewMaster.is_sb04_dev?

    @menu_header3 = 'sb0404menu'
    @menu_title3  = 'コード管理'
    @menu_header4 = 'sb04stafflists'
    @menu_title4  = '職員一覧'
    if @prm_pattern == :csv # CSV 追加済一覧で使用する選択 設定
      @grped_id = nz(params[:grped_id],0)
    else
      # 年度選択　設定
        # 年度変更時は、所属選択をクリア
      if params[:fyed_id]
        if params[:pre_fyear] != params[:fyed_id]
          params[:grped_id] = nil
        end
      else
          params[:grped_id] = nil
      end
      # 年度選択　設定
      # 指定がない場合、管理者は作業中の年度、一般は公開後の年度
      @fyed_id = nz(params[:fyed_id],0)
      # 初期値は「すべて」
      # 所属選択　設定
      all = nil
      if params[:grped_id].to_i == 0
        all = 'all'
      end
      @grped_id = Gwsub.set_section_select(@fyed_id , params[:grped_id] , all)
    end
    # 表示行数　設定
    @limits = nz(params[:limit],30)
    # 兼務表示　設定
    @multi_section = nz(params[:multi_section],'1')

    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current = '05'
    @l2_current = '01'
    case @multi_section.to_i
    when 1
      @l3_current = '01'
    when 2
      @l3_current = '02'
    else
      @l3_current = '01'
    end

    # 絞込条件の持ち回り
    set_param
    @csv_base_url = "/gwsub/sb04/04/sb04stafflists"

    @ie = Gw.ie?(request)
  end
  def search_condition
    params[:fyed_id] = nz(params[:fyed_id],@fyed_id)
    params[:grped_id] = nz(params[:grped_id],@grped_id)
    params[:limit] = nz(params[:limit], @limits)
    params[:multi_section]  = nz(params[:multi_section], @multi_section )
    @s_keyword = nil
    @s_keyword = params[:s_keyword] unless params[:s_keyword].blank?

    qsa = ['limit', 's_keyword' ,'fyed_id','grped_id' ,'pre_fyear' , 'v' ,'multi_section' ,'idx' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')

  end
  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'fyear_markjp DESC , section_code ASC , kana ASC , staff_no aSC')
  end

  def section_fields
    @fyed_id = nz(params[:fyed_id],@fyed_id)

    sections = Gwsub::Sb04section.sb04_group_select(@fyed_id.to_i , 'notall' )
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

  def sb04_dev_section_fields
    @fyed_id = nz(params[:fyed_id],@fyed_id)

    sections = Gwsub::Sb04stafflistviewMaster.sb04_dev_group_select(@fyed_id.to_i)
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

  def assignedjobs_fields
    params[:fyed_id] = nz(params[:fyed_id],@fyed_id)
    @fyed_id = params[:fyed_id]

    sections = Gwsub::Sb04section.sb04_group_select(@fyed_id.to_i , 'notall' )
    if params[:grped_id].to_i == 0
      @grped_id = sections[0][1]
    else
      @grped_id = params[:grped_id].to_i
    end
    assignedjobs = Gwsub::Sb04assignedjob.sb04_assignedjobs_id_select(@fyed_id.to_i,@grped_id.to_i)

    _html_select = ''
    if assignedjobs.blank?
        _html_select << "<option value='0'>担当未設定</option>"
    else
      assignedjobs.each do |value,key|
        _html_select << "<option value='#{key}'>#{value}</option>"
      end
    end
    respond_to do |format|
      format.csv { render :text => _html_select ,:layout=>false ,:locals=>{:f=>@item} }
    end
  end

  def officialtitles_fields
    params[:fyed_id] = nz(params[:fyed_id],@fyed_id)
    @fyed_id = params[:fyed_id]

    officialtitles = Gwsub::Sb04officialtitle.sb04_official_titles_select(@fyed_id.to_i)
    _html_select = ''
    if officialtitles.blank?
        _html_select << "<option value='0'>職名未設定</option>"
    else
      _html_select << "<option value=''></option>"
      officialtitles.each do |value,key|
        _html_select << "<option value='#{key}'>#{value}</option>"
      end
    end
    respond_to do |format|
      format.csv { render :text => _html_select ,:layout=>false ,:locals=>{:f=>@item} }
    end
  end

  def master_sections_fields
    params[:section_id] = nz(params[:section_id], 0)
    @section_id = params[:section_id].to_i

    section_item = Gwsub::Sb04section.new.find(:first, :conditions=>["id = ?", @section_id])
    staffs =  section_item.staffs
    _html_select = ''
    staffs.each do |value|
      _html_select << "<option value='#{value.id}'>(#{value.staff_no})#{value.name}</option>"
    end

    respond_to do |format|
      format.csv { render :text => _html_select ,:layout=>false ,:locals=>{:f=>@item} }
    end
  end

  def csvput
    init_params
    @l3_current = '04'
    if params[:item].nil?
      return
    end

    par_item = params[:item]
    nkf_options = case par_item[:nkf]
        when 'utf8'
          '-w'
        when 'sjis'
          '-s'
        end
    case par_item[:csv]
    when 'put'
      filename = "sb04_stafflists_backup_#{par_item[:nkf]}.csv"
      staff_order = "fyear_id DESC , section_code ASC , assignedjobs_code ASC , divide_duties_order ASC"
        items = Gwsub::Sb04stafflist.find(:all,:order=>staff_order)
      if items.blank?
      else
        file = Gw::Script::Tool.ar_to_csv(items)
        send_data(NKF::nkf(nkf_options,file) , :filename=>"#{filename}" )
      end
    else
    end
    return
  end

  def csvup
    init_params
    @l3_current = '05'
    if params[:item].nil?
#      return
    end

    flash[:notice]="現在、CSV出力メニューから出力したデータの再登録機能は提供しておりません。"
    return redirect_to "#{@csv_base_url}"

    par_item = params[:item]
    case par_item[:csv]
    when 'up'
      if par_item.nil? || par_item[:nkf].nil? || par_item[:file].nil?
        flash[:notice] = 'ファイル名を指定してください。'
      else
        upload_data = par_item[:file]
        f = upload_data.read
        nkf_options = case par_item[:nkf]
        when 'utf8'
          '-w -W'
        when 'sjis'
          '-w -S'
        end
        file =  NKF::nkf(nkf_options,f)
        if file.blank?
        else
          Gwsub::Sb04stafflist.truncate_table
          s_to = Gwsub::Script::Tool.import_csv_sb04_staff(file, "gwsub_sb04stafflists")
        end
#        location = Gw.chop_with("#{Site.current_node.public_uri}",'/')
#        redirect_to location
      end
    else
    end
    return
  end

  def csvadd_check
    init_params
    return authentication_error(403) unless @u_role == true
    @l3_current = '06'
    return
  end

  def csvadd_check_run
    init_params
    return authentication_error(403) unless @u_role == true
    location = "#{@csv_base_url}/csvadd_check?#{@qs}"

    @l3_current = '06'
    if params[:item].nil?
      return redirect_to location
    end
    if params[:item][:file].blank?
      flash[:notice] = '対象ファイルを指定してください。'
      return redirect_to location
    end

    par_item = params[:item]
    case par_item[:csv]
    when 'add'
      if par_item[:fyed_id].present?
        @fyed_id = nz(par_item[:fyed_id], 0).to_i
        check = Gwsub::Sb04CheckStafflist.csv_check(params)
        if check[:result]
          flash[:notice] = '正常にインポートされました。'
          return redirect_to "#{@csv_base_url}/index_csv?#{@qs}"
        else
          flash[:notice] = check[:error_msg]
          if check[:error_kind] == 'csv_error'
            file = Gw::Script::Tool.ary_to_csv(check[:csv_data])
            nkf_options = case par_item[:nkf]
            when 'utf8'
              '-w -W'
            when 'sjis'
              '-s -W'
            end
            fyear = Gw::YearFiscalJp.find(:first, :conditions=>["id = ? ", par_item[:fyed_id]],:order=>"start_at DESC")
            filename = "#{fyear.markjp}_40職員_エラー箇所追記.csv"
            filename = NKF::nkf('-s -W', filename) if @ie
            send_data( NKF::nkf(nkf_options, file) , :filename => filename )
          else
            return redirect_to location
          end
        end
      else
        flash[:notice] = '年度を指定してください。'
        return redirect_to location
      end
    else
    end
  end

  def stafflists_create
    init_params
    return authentication_error(403) unless @u_role == true
    @l3_current = '07'
#    return if params[:item].nil?
  end
  def stafflists_create_run
    init_params
    return authentication_error(403) unless @u_role == true
    @l3_current = '07'
    return redirect_to "#{@csv_base_url}/sb04stafflists_create?#{@qs}" if params[:item].nil?

    par_item = params[:item]
    case par_item[:csv]
    when 'import'
      fyear_id = params[:item][:fyear_id]

      if fyear_id.blank?
        flash.now[:notice] = '年度が異常です。管理者に確認して下さい。'
          location = "#{@csv_base_url}/stafflists_create?#{@qs}"
          return redirect_to location
      else
        fyear_id = fyear_id.to_i
        check = Gwsub::Sb04CheckStafflist.check_fyear_id_all(fyear_id)
        if check[:flg] == true
          # データの入力
          Gwsub::Sb04CheckOfficialtitle.import_table(fyear_id)
          Gwsub::Sb04CheckSection.import_table(fyear_id)
          Gwsub::Sb04CheckAssignedjob.import_table(fyear_id)
          Gwsub::Sb04CheckStafflist.import_table(fyear_id)

          Gwsub::Sb04CheckOfficialtitle.truncate_table
          Gwsub::Sb04CheckSection.truncate_table
          Gwsub::Sb04CheckAssignedjob.truncate_table
          Gwsub::Sb04CheckStafflist.truncate_table
          flash[:notice] = '電子職員録を作成いたしました。CSV仮データをクリアしました。'
          location = "/gwsub/sb04/01/sb04stafflistview"
          return redirect_to location
        else
          flash[:notice] = check[:msg]
          location = "#{@csv_base_url}/stafflists_create?#{@qs}"
          return redirect_to location
        end
      end
    else
      flash[:notice] = "処理対象がありませんでした。"
      location = "#{@csv_base_url}/stafflists_create?#{@qs}"
      return redirect_to location
    end
    flash[:notice] = "処理対象がありませんでした。"
    location = "#{@csv_base_url}/stafflists_create?#{@qs}"
    return redirect_to location
  end

  def index_csv
    @prm_pattern = :csv
    init_params
    return authentication_error(403) unless @u_role == true
    item = Gwsub::Sb04CheckStafflist.new #.readable
    item.search params

    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    @l3_current = '08'
  end

  def show_csv
    @prm_pattern = :csv
    init_params
    return authentication_error(403) unless @u_role == true
    @item = Gwsub::Sb04CheckStafflist.find_by_id(params[:id])
    return http_error(404) if @item.blank?
    @l3_current = '08'
  end

  def year_copy
    init_params
    return authentication_error(403) if @u_role != true && @role_sb04_dev != true
    @l3_current = '09'
    @ret = nil
    return
  end

  def year_copy_run
    init_params
    return authentication_error(403) if @u_role != true && @role_sb04_dev != true
    @l3_current = '09'
    @ret = nil
    if params[:item].nil?
      flash[:notice] = "コピー元・コピー先が指定されていません。条件を設定してください。"
      location = "/gwsub/sb04/04/sb04stafflists/year_copy?#{@qs}"
      return redirect_to location
    end
    par_item = params[:item]
    case par_item[:copy]
    when 'copy'
      @ret = Gwsub::Sb04stafflist.year_copy_stafflists(par_item, {:u_role => @u_role, :role_sb04_dev => @role_sb04_dev})
    else
    end
    flash[:notice] = @ret[:msg][0]       if @ret[:result]==true
    flash[:notice] = @ret[:msg][0][1]    if @ret[:result]!=true
    location = "/gwsub/sb04/04/sb04stafflists/year_copy?#{@qs}"
    return redirect_to location
  end

  def set_param
#    @param = "?"
#    @param += "pre_fyear=#{@fyed_id}&"            unless @fyed_id.blank?
#    @param += "fyed_id=#{@fyed_id}&"              unless @fyed_id.blank?
#    @param += "grped_id=#{@grped_id}&"            unless @grped_id.blank?
#    @param += "multi_section=#{@multi_section}&"  unless @multi_section.blank?
#    @param += "limit=#{@limits}&"                 unless @limits.blank?
#    @param += "s_keyword=#{@s_keyword}&"          unless @s_keyword.blank?
#    if @param == "?"
#      @param=nil
#    else
#      @param = Gw.chop_with(@param,'&')
#    end
    @param = nil
    return @param
  end

end
