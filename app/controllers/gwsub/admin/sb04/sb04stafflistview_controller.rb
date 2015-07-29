# -*- encoding: utf-8 -*-
class Gwsub::Admin::Sb04::Sb04stafflistviewController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  layout "admin/template/portal_1column"

  def initialize_scaffold
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    @page_title = "電子職員録"
  end
  def index
    init_params
    item = Gwsub::Sb04stafflist.new #.readable
    item.personal_state = '1'
    item.and "sql" , Gwsub::Sb04stafflist.staff_select(@u_role || @role_sb04_dev)
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end

  def show
    init_params
    @item = Gwsub::Sb04stafflist.find(params[:id])
    return http_error(404) if @item.blank?

    item = Gwsub::Sb04stafflist.new
    item.personal_state = '1'
    item.fyear_id = @item.fyear_id unless @item.fyear_id.to_i==0
    item.section_id = @item.section_id unless @item.section_id.to_i==0
    item.section_name = @item.section_name unless @item.section_name==""
    item.assignedjobs_id = @item.assignedjobs_id unless @item.assignedjobs_id.to_i==0
    item.order "divide_duties_order_int"
    @items = item.find(:all)
    _show @item
  end

  def new
    init_params
    item1 = Gwsub::Sb04stafflist.find(params[:show])
    item = Gwsub::Sb04stafflist.new
    item.fyear_id = item1.fyear_id unless item1.fyear_id.to_i==0
    item.section_id = item1.section_id unless item1.section_id.to_i==0
    item.assignedjobs_id = item1.assignedjobs_id unless item1.assignedjobs_id.to_i==0
    item.order "divide_duties_order_int"
    @items = item.find(:all)
    @item = Gwsub::Sb04stafflist.new({
        :fyear_id => item1.fyear_id ,
        :section_id => item1.section_id
      })
  end
  def create
    init_params
    @item = Gwsub::Sb04stafflist.find_by_id(params['item_user_id'])
    return http_error(404)

    params[:item]['id'] = @item.id
    @item.attributes = params[:item]
    _update(@item,{:location=>"#{@csv_base_url}/#{params[:item]['user_id']}?#{@qs}"} )
  end

  def edit
    init_params
    @item = Gwsub::Sb04stafflist.find_by_id(params[:id])
    return http_error(404) if @item.blank?

    item = Gwsub::Sb04stafflist.new
    item.fyear_id = @item.fyear_id unless @item.fyear_id.to_i==0
    item.section_id = @item.section_id unless @item.section_id.to_i==0
    item.assignedjobs_id = @item.assignedjobs_id unless @item.assignedjobs_id.to_i==0
    item.order "divide_duties_order_int"
    @items = item.find(:all)
  end
  def update
    init_params
    @item = Gwsub::Sb04stafflist.find_by_id(params[:id])
    return http_error(404) if @item.blank?

    @item.attributes = params[:item]
    # 更新後は詳細画面を表示
    _update(@item,{:location=>"#{@csv_base_url}/#{@item.id}?#{@qs}"})
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb04stafflist.is_dev?(Core.user.id)
    @role_admin      = Gwsub::Sb04stafflist.is_admin?(Core.user.id)
    @u_role = @role_developer || @role_admin
    @menu_header3 = 'sb04stafflistview'
    @menu_title3  = '職員録'

    # 電子職員録 主管課権限設定
    @role_sb04_dev  = Gwsub::Sb04stafflistviewMaster.is_sb04_dev?

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
    @fyed_id = Gwsub.set_fyear_select(params[:fyed_id],{:role=>@u_role || @role_sb04_dev})
    # 所属選択　設定
    @grped_id = Gwsub.set_section_select(@fyed_id , params[:grped_id])
    all = nil
    if params[:grped_id].to_i == 0
      all = 'all'
      @grped_id = Gwsub.set_section_select(@fyed_id , params[:grped_id] , all)
    else
      @grped_id = params[:grped_id]
      @fyed_id = Gwsub::Sb04section.find(@grped_id.to_i).fyear_id
      params[:fyed_id]    = @fyed_id
      params[:pre_fyear]  = @fyed_id
    end
#    # 所属選択は、年度指定との同時検索に対応する　
    # 表示行数　設定
    @limits = nz(params[:limit], Gwsub::Sb04LimitSetting.get_stafflistview_limit)

    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current = '01'
    @l2_current = '01'

    # 絞込条件の持ち回り
    set_param
    @csv_base_url = "/gwsub/sb04/01/sb04stafflistview"
  end

  def search_condition
    params[:fyed_id]  = nz(params[:fyed_id],@fyed_id)
    params[:grped_id] = nz(params[:grped_id],@grped_id)
    params[:limit]    = nz(params[:limit], @limits)
    @s_keyword = nil
    @s_keyword = params[:s_keyword] unless params[:s_keyword].blank?

    qsa = ['limit' , 's_keyword' , 'pre_fyear' , 'fyed_id' , 'grped_id' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')

  end
  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'fyear_id DESC , section_code ASC , assignedjobs_code_int ASC , divide_duties_order_int ASC')
  end

  def csvput
    # 項目指定CSV
    init_params
    @l2_current = '03'

    return if params[:item].nil?
    par_item = params[:item]
    nkf_options = case par_item[:nkf]
        when 'utf8'
          '-w'
        when 'sjis'
          '-s'
        end
    case par_item[:csv]
    when 'put'
      if par_item[:fyed_id].blank?
        flash[:notice] = "年度を指定してください。"
        return
      end
      if par_item[:grped_id].blank?
        flash[:notice] = "対象所属または「すべて」を指定してください。"
        return
      end
      staff = Gwsub::Sb04stafflist.new
      # 出力条件指定
      staff.fyear_id    = par_item[:fyed_id].to_i   unless par_item[:fyed_id].to_i == 0
      staff.section_id  = par_item[:grped_id].to_i  unless par_item[:grped_id].to_i == 0
      # ソート順指定
      staff.order params[:id], @sort_keys
      # 出力項目指定
      if par_item[:select]=='all'
        select = "section_code,section_name,assignedjobs_code,assignedjobs_name,divide_duties_order,assignedjobs_tel,staff_no,divide_duties,official_title_name,name,name_print,kana,extension,remarks"
      else
        cols = par_item[:chks].to_a.sort.collect{|k,v| v}
        sel_cols = cols.join(',')
        select = "section_code,section_name,assignedjobs_name,assignedjobs_tel,staff_no,official_title_name,name"
        select += ",#{sel_cols}" if !sel_cols.blank?
      end
      # 出力データ抽出
      staffs = staff.find(:all,:select=>select)
      if staffs.blank?
        flash[:notice] = "出力データはありませんでした。"
      else
        fyear_markjp = Gw::YearFiscalJp.find(par_item[:fyed_id]).markjp
        select_jp = select_to_jp(select,'gwsub_sb04_stafflists_to_jp')
        group_code = 'all' if par_item[:grped_id].to_i == 0
        group_code = staffs[0].section_code unless par_item[:grped_id].to_i == 0
        filename = "#{fyear_markjp}_Stafflist#{group_code}_#{par_item[:nkf]}.csv"
        file = Gw::Script::Tool.ar_to_csv(staffs, :cols=>select,:header=>false)
        select_jp << "\n"
        select_jp << file
        send_data(NKF::nkf(nkf_options,select_jp) , :filename=>"#{filename}" )
      end
    else
    end
  end
  def csvview
    # 電子職員録
    init_params
    @l2_current = '02'
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
    case par_item[:file]
    when 'put'
      if par_item[:fyed_id].blank?
        flash[:notice] = "年度を指定してください。"
        return
      end
      if par_item[:grped_id].blank?
        flash[:notice] = "対象所属または「すべて」を指定してください。"
        return
      end
      staff = Gwsub::Sb04stafflist.new
      # 出力条件指定
      staff.fyear_id    = par_item[:fyed_id].to_i   unless par_item[:fyed_id].to_i == 0
      staff.section_id  = par_item[:grped_id].to_i  unless par_item[:grped_id].to_i == 0
      staff.assignedjobs_code_int = 10              if par_item[:form] == "pdf" && par_item[:executive] == "1"
      # ソート順指定
      staff.order params[:id], @sort_keys
      # 出力項目

      if par_item[:form] == "csv"
        select = "section_name,assignedjobs_address,assignedjobs_name,assignedjobs_tel,staff_no,official_title_name,name,name_print,remarks"
      else
        if par_item[:executive] == "1"
          select = "section_name,staff_no,official_title_name,name"
        else
          select = "section_name,assignedjobs_name,assignedjobs_tel,staff_no,official_title_name,name"
        end
      end
      # 出力データ抽出
      staffs = staff.find(:all,:select=>select)
      if staffs.blank?
        flash[:notice] = "出力データはありませんでした。"
      else
        fyear_markjp = Gw::YearFiscalJp.find(par_item[:fyed_id]).markjp
        select_jp = select_to_jp(select,'gwsub_sb04_stafflists_view_to_jp')
        group_code = 'all' if par_item[:grped_id].to_i == 0
        group_code = NKF::nkf('-s',staffs[0].section_name) unless par_item[:grped_id].to_i == 0

        if par_item[:form] == "csv"
          filename = "#{fyear_markjp}_Syokuinroku_#{group_code}_#{par_item[:nkf]}.csv"
          file = Gwsub::Script::Tool.stafflistview_to_csv(staffs, :cols=>select,:header=>false,:quotes=>true)
          select_jp << "\n"
          select_jp << file
          send_data(NKF::nkf(nkf_options,select_jp) , :filename=>"#{filename}" )
        end
      end
    else
    end
  end

  def select_to_jp(select,to_jp_header='gwsub_sb04_stafflists_view_to_jp')
    select_jp = []
    select_org = select.split(',')
    to_jp_ar = Gw.yaml_to_array_for_select to_jp_header
    to_jp = []
    to_jp_ar.each do |value,key|
      to_jp << [key,value]
    end
    select_org.each do |key|
      select_jp << to_jp.assoc(key)[1] unless to_jp.assoc(key).blank?
    end
    return select_jp.join(',').to_s
  end

  def section_fields
    @fyed_id = Gwsub.set_fyear_select(params[:fyed_id])
    params[:fyed_id] = nz(params[:fyed_id],@fyed_id)

    @sections = Gwsub::Sb04section.sb04_group_select(@fyed_id.to_i , nil )
    _html_select = ''
    @sections.each do |value , key|
      _html_select << "<option value='#{key}'>#{value}</option>"
    end
    respond_to do |format|
      format.csv { render :text => _html_select ,:layout=>false ,:locals=>{:f=>@item} }
    end
  end

  def set_param
#    @param = "?"
#    @param += "pre_fyear=#{@fyed_id}&"          unless @fyed_id.blank?
#    @param += "fyed_id=#{@fyed_id}&"            unless @fyed_id.blank?
#    @param += "grped_id=#{@grped_id}&"          unless @grped_id.blank?
#    @param += "limit=#{@limits}&"               unless @limits.blank?
#    @param += "s_keyword=#{@s_keyword}&"        unless @s_keyword.blank?
#    if @param == "?"
#      @param=nil
#    else
#      @param = Gw.chop_with(@param,'&')
#    end
    @param = nil
    return @param
  end
end
