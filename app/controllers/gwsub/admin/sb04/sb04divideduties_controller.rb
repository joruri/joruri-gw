# -*- encoding: utf-8 -*-
class Gwsub::Admin::Sb04::Sb04dividedutiesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  layout "admin/template/portal_1column"

  def initialize_scaffold
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    @page_title = "電子事務分掌表"
  end

  def index
    init_params

    item = Gwsub::Sb04stafflist.new #.readable
    item.display_state = '1'
    item.and "sql" , Gwsub::Sb04stafflist.staff_select(@u_role)
    if params[:fyed_id].blank?
      year_fiscal_jp = Gw::YearFiscalJp.get_record(Time.now)
      if year_fiscal_jp.blank?
        fyed_id = 0
      else
        fyed_id = year_fiscal_jp.id
      end
    else
      fyed_id = params[:fyed_id]
    end

    @published = Gwsub::Sb04EditableDate.today_published?(fyed_id) # 当日が、公開しているかどうか選択
    @edit_period = Gwsub::Sb04EditableDate.today_edit_period?(fyed_id) # 当日が、編集期間中かどうか確認する
    if @role_sb04_dev && (@published == false)
      gids = Gwsub::Sb04stafflistviewMaster.get_division_sb04_gids # ログインユーザーの主管課範囲のコード
      condition = Condition.new()
      condition.and do |cond|
        gids.each do |gid|
          cond.or 'section_id', '=', gid
        end
      end
      item.and condition
    end
    item.search params
#    item.creator
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys

    @items = item.find(:all)
    _index @items
  end
  def show
    init_params
    @item = Gwsub::Sb04stafflist.find(params[:id])
    # 同一年度・所属・担当（表示用）
    item  = Gwsub::Sb04stafflist.new
    # 職員録表示対象のみ
    item.display_state = '1'
    if @item.fyear_id.to_i==0
      item.fyear_markjp       = @item.fyear_markjp
    else
      item.fyear_id           = @item.fyear_id
    end
    if @item.section_id.to_i==0
      item.section_code       = @item.section_code
    else
      item.section_id         = @item.section_id
    end
    if @item.assignedjobs_id.to_i ==  0
      item.assignedjobs_code  = @item.assignedjobs_code
    else
      item.assignedjobs_id    = @item.assignedjobs_id
    end
    item.section_name         = @item.section_name        unless @item.section_name.to_s.blank?
    item.order "divide_duties_order_int"
    @items = item.find(:all)
    @fyed_id    = @item.fyear_id        unless @item.fyear_id.to_i        ==  0
    @grped_id   = @item.section_id      unless @item.section_id.to_i      ==  0
    set_param
    _show @item
  end

  def new
    # 所属・担当をまたぐ、兼務追加
    init_params
    # 同一年度・所属・担当（表示用）
    item1 = Gwsub::Sb04stafflist.find_by_id(params[:show])
    return http_error(404) if item1.blank?

    item  = Gwsub::Sb04stafflist.new
    if item1.fyear_id.to_i==0
      item.fyear_markjp       = item1.fyear_markjp
    else
      item.fyear_id           = item1.fyear_id
    end
    if item1.section_id.to_i==0
      item.section_code       = item1.section_code
    else
      item.section_id         = item1.section_id
    end
    if item1.assignedjobs_id.to_i ==  0
      item.assignedjobs_code  = item1.assignedjobs_code
    else
      item.assignedjobs_id    = item1.assignedjobs_id
    end
    item.order "divide_duties_order_int"
    @items = item.find(:all)
    @item = Gwsub::Sb04stafflist.new({
        :fyear_id           => item1.fyear_id ,
        :section_id         => item1.section_id,
        :assignedjobs_id    => item1.assignedjobs_id  ,
        :multi_section_flg  =>  '2'
      })
  end
  def create
    # 所属・担当をまたぐ、兼務追加
    init_params

#pp params
    add_multi_user                  = Gwsub::Sb04stafflist.find(params['item_user_id'])
    @item                           = Gwsub::Sb04stafflist.new
    @item.fyear_id                  = params[:item]['fyear_id']
    @item.staff_no                  = add_multi_user.staff_no
    @item.multi_section_flg         = params[:item]['multi_section_flg']
    @item.name                      = add_multi_user.name
    @item.name_print                = add_multi_user.name_print
    @item.kana                      = add_multi_user.kana
    @item.section_id                = params[:item]['section_id']
    @item.assignedjobs_id           = params[:item]['assignedjobs_id']
    @item.official_title_id         = params[:item]['official_title_id']
    @item.categories_id             = params[:item]['categories_id']
    @item.extension                 = params[:item]['extension']
    @item.divide_duties             = params[:item]['divide_duties']
    @item.divide_duties_order       = params[:item]['divide_duties_order']
    @item.remarks                   = params[:item]['remarks']
    @item.personal_state            = '1'
    @item.display_state             = '1'
    # 同一年度・所属・担当（表示用）
    item1 = Gwsub::Sb04stafflist.find(params[:show])
    item  = Gwsub::Sb04stafflist.new
    item.fyear_id         = item1.fyear_id          unless item1.fyear_id.to_i        ==  0
    item.section_id       = item1.section_id        unless item1.section_id.to_i      ==  0
    item.assignedjobs_id  = item1.assignedjobs_id   unless item1.assignedjobs_id.to_i ==  0
    item.order "divide_duties_order_int"
    @items = item.find(:all)
    # 登録後は、選択したユーザーの詳細表示。
    location = "#{@csv_base_url}/#{params[:item]['user_id']}?#{@qs}"
    options = {:location=>location}
    _create(@item,options)
  end

  def edit
    # 編集（担当変更を含む）
    init_params
    @item = Gwsub::Sb04stafflist.find(params[:id])

    # 同一年度・所属・担当（表示用）
    item = Gwsub::Sb04stafflist.new
    item.display_state = '1'
    if @item.fyear_id.to_i==0
      item.fyear_markjp       = @item.fyear_markjp
    else
      item.fyear_id           = @item.fyear_id
    end
    if @item.section_id.to_i==0
      item.section_code       = @item.section_code
    else
      item.section_id         = @item.section_id
    end
    if @item.assignedjobs_id.to_i ==  0
      item.assignedjobs_code  = @item.assignedjobs_code
    else
      item.assignedjobs_id    = @item.assignedjobs_id
    end
    item.order "divide_duties_order_int"
    @items = item.find(:all)
    @fyed_id = @item.fyear_id     unless @item.fyear_id.to_i        ==  0
    @grped_id = @item.section_id  unless @item.section_id.to_i      ==  0
    # 絞込条件の持ち回り
    set_param
  end
  def update
    # 編集（担当変更を含む）
    init_params
    @item = Gwsub::Sb04stafflist.find_by_id(params[:id])

    # 同一年度・所属・担当（表示用）
    item = Gwsub::Sb04stafflist.new
    item.display_state = '1'
    item.fyear_id         = @item.fyear_id         unless @item.fyear_id.to_i        ==  0
    item.section_id       = @item.section_id       unless @item.section_id.to_i      ==  0
    item.assignedjobs_id  = @item.assignedjobs_id  unless @item.assignedjobs_id.to_i ==  0
    item.order "divide_duties_order_int"
    @items = item.find(:all)

    if Gwsub::Sb04dividedutie.dividedutie_data_save(params, @item, :update)
      @item.attributes = params[:item]

      # 更新後は詳細画面を表示
      location = "#{@csv_base_url}/#{@item.id}?#{@qs}"
      options = {:location=>location}
      _update(@item,options)
    else
      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def add
    # 同一所属内で本務に担当を割当
    init_params
    item1 = Gwsub::Sb04stafflist.find(params[:show])
    item  = Gwsub::Sb04stafflist.new
    if item1.fyear_id.to_i==0
      item.fyear_markjp       = item1.fyear_markjp
    else
      item.fyear_id           = item1.fyear_id
    end
    if item1.section_id.to_i==0
      item.section_code       = item1.section_code
    else
      item.section_id         = item1.section_id
    end
    if item1.assignedjobs_id.to_i ==  0
      item.assignedjobs_code  = item1.assignedjobs_code
    else
      item.assignedjobs_id    = item1.assignedjobs_id
    end
    item.order "divide_duties_order_int"
    @items = item.find(:all)
    @item = Gwsub::Sb04stafflist.new({
        :fyear_id => item1.fyear_id ,
        :section_id => item1.section_id
      })
    @fyed_id  = @item.fyear_id    unless item1.fyear_id.to_i        ==  0
    @grped_id = @item.section_id  unless item1.section_id.to_i      ==  0
    # 絞込条件の持ち回り
    set_param
  end
  def add_update
    # 同一所属内で本務に担当を割当
    init_params
    @item = Gwsub::Sb04stafflist.find(params['item_user_id'])
    @item.attributes  = params[:item]
    location = "#{@csv_base_url}/#{@item.id}#{@qs}"
    options = {:location=>location}
    _update(@item,options)
  end

  def assigned_job_edit
    # 担当　電話・住所　編集
    init_params
    #編集フォームを表示
    @item = Gwsub::Sb04stafflist.find_by_id(params[:id])
    return http_error(404) if @item.blank?

    # 同じ所属・担当のユーザーを取得
    item = Gwsub::Sb04stafflist.new
    item.display_state = '1'
    if @item.fyear_id.to_i==0
      item.fyear_markjp       = @item.fyear_markjp
    else
      item.fyear_id           = @item.fyear_id
    end
    if @item.section_id.to_i==0
      item.section_code       = @item.section_code
    else
      item.section_id         = @item.section_id
    end
    if @item.assignedjobs_id.to_i ==  0
      item.assignedjobs_code  = @item.assignedjobs_code
    else
      item.assignedjobs_id    = @item.assignedjobs_id
    end
    item.order "divide_duties_order_int"
    @items = item.find(:all)
    # 編集対象（担当）の取得
    if @item.assignedjobs_id.to_i==0
      @assigned_job = Gwsub::Sb04assignedjob.new
    else
      @assigned_job = Gwsub::Sb04assignedjob.find_by_id(@item.assignedjobs_id)
      if @assigned_job.blank?
        @assigned_job = Gwsub::Sb04assignedjob.new
      end
    end
  end
  def assigned_job_update
    # 担当　電話・住所　編集
    init_params
    # 表示対象データを取得
    @item = Gwsub::Sb04stafflist.find(params[:id])
    return http_error(404) if @item.blank?
    # 入力データを取得し、担当データ更新
    assigned_job = Gwsub::Sb04assignedjob.find_by_id(@item.assignedjobs_id)
    return http_error(404) if assigned_job.blank?

    assigned_job.attributes =params[:assigned_job]
    assigned_job.save(:validate=>false)
    # 同じ所属・担当のユーザーを取得
    item = Gwsub::Sb04stafflist.new
    item.display_state = '1'
    if @item.fyear_id.to_i==0
      item.fyear_markjp       = @item.fyear_markjp
    else
      item.fyear_id           = @item.fyear_id
    end
    if @item.section_id.to_i==0
      item.section_code       = @item.section_code
    else
      item.section_id         = @item.section_id
    end
    if @item.assignedjobs_id.to_i ==  0
      item.assignedjobs_code  = @item.assignedjobs_code
    else
      item.assignedjobs_id    = @item.assignedjobs_id
    end
    item.order "divide_duties_order_int"
    items = item.find(:all)
    # 入力結果を反映
    items.each do |staff|
      # 上書き保存だけすれば、担当情報はモデル内で自動更新する
      staff.save
    end
    # 詳細表示データ取得
    item = Gwsub::Sb04stafflist.new
    item.display_state = '1'
    if @item.fyear_id.to_i==0
      item.fyear_markjp       = @item.fyear_markjp
    else
      item.fyear_id           = @item.fyear_id
    end
    if @item.section_id.to_i==0
      item.section_code       = @item.section_code
    else
      item.section_id         = @item.section_id
    end
    if @item.assignedjobs_id.to_i ==  0
      item.assignedjobs_code  = @item.assignedjobs_code
    else
      item.assignedjobs_id    = @item.assignedjobs_id
    end
    item.order "divide_duties_order_int"
    @items = item.find(:all)
    # 更新後は詳細画面を表示
    location = "#{@csv_base_url}/#{@item.id}?#{@qs}"
    redirect_to location
    return
  end

  def destroy
    # 兼務追加のみ削除可能
    init_params
    @item = Gwsub::Sb04stafflist.find(params[:id])
    return http_error(404) if @item.blank?
    # 更新後は所属画面を表示
    location = "#{@csv_base_url}?#{@param}"
    options = {:location=>location}
    _destroy(@item,options)
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb04stafflist.is_dev?(Core.user.id)
    @role_admin      = Gwsub::Sb04stafflist.is_admin?(Core.user.id)
    @u_role = @role_developer || @role_admin

    # 電子職員録 主管課権限設定
    @role_sb04_dev  = Gwsub::Sb04stafflistviewMaster.is_sb04_dev?

    @menu_header3 = 'sb04divideduties'
    @menu_title3  = '事務分掌'
    @menu_header4 = 'sb04divideduties'

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
    @fyed_id = Gwsub.set_fyear_select(params[:fyed_id],{:role=>@u_role})
    # 初期値は「すべて」
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
    # 所属選択は、年度指定との同時検索に対応する　
    # 表示行数　設定
    @limits = nz(params[:limit], Gwsub::Sb04LimitSetting.get_divideduties_limit)
    # 座席表を開く時のリンクで表示するツールチップ
    @bbs_link_title   = "別ウィンドウ・別タブで開きます"

    @s_keyword  = nz(params[:s_keyword],nil)
    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current = '02'
    @l2_current = '01'

    # 絞込条件の持ち回り
    set_param
    @csv_base_url = "/gwsub/sb04/02/sb04divideduties"
  end
  def search_condition
    params[:fyed_id] = nz(params[:fyed_id],@fyed_id)
    params[:grped_id] = nz(params[:grped_id],@grped_id)
    params[:limit] = nz(params[:limit], @limits)
    @s_keyword = nil
    @s_keyword = params[:s_keyword] unless params[:s_keyword].blank?

    qsa = ['limit', 's_keyword' ,'fyed_id','grped_id' ,'pre_fyear']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')

  end
  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'fyear_id DESC , section_code ASC , assignedjobs_code_int ASC , divide_duties_order_int ASC')
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
    @param  = nil
    return  @param
  end

end
