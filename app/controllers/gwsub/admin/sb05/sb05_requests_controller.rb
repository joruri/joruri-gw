class Gwsub::Admin::Sb05::Sb05RequestsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
#  include Gwsub::Controller::Recgnize
#  include Gwsub::RecognizersHelper
  layout "admin/template/portal_1column"

  def pre_dispatch
   return redirect_to(request.env['PATH_INFO']) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "広報依頼"
  end

  def index
    # 希望日順（default）
    init_params
    params.delete 'cat_code'
    @l2_current = '02'
    item = Gwsub::Sb05Request.new
    item.search params
    item.and 'sql','start_at is not null'
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @requests = item.find(:all)
    _index @requests
  end
  def index_created_dates
    # 依頼日順
    init_params
    params.delete 'cat_code'
    @l2_current = '03'
    @sort_keys = nz(params[:sort_keys], 'created_at DESC , start_at ASC , end_at ASC , media_code ASC , categories_code ASC')
    item = Gwsub::Sb05Request.new
    item.search params
    item.and 'sql','start_at is not null'
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @requests = item.find(:all)
  end
  def index_before_publish
    # 未処理一覧
    init_params
    return error_auth unless @u_role==true

    params.delete 'cat_code'
    @l2_current = '04'
    @m_status   = 0      # 確認は「すべて」
    @r_status   = 4      # 未処理
    params[:m_status]   = 0
    params[:r_status]   = 4
    item = Gwsub::Sb05Request.new
    item.search params
    item.and 'sql','start_at is not null'
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @requests = item.find(:all)
  end
  def index_before_confirm
    # 未確認一覧
    init_params
    return error_auth unless @u_role==true

    params.delete 'cat_code'
    @l2_current = '05'
    @m_status   = 1      # 未確認
    @r_status   = 0      # 処理は「すべて」
    params[:m_status]   = 1
    params[:r_status]   = 0
    item = Gwsub::Sb05Request.new
    item.search params
    item.and 'sql','start_at is not null'
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @requests = item.find(:all)
  end

  def show
    init_params
    @req1 = Gwsub::Sb05Request.find(params[:id])
    user_id = nz(params[:sb05_users_id],@req1.sb05_users_id)
    @user = Gwsub::Sb05User.find(user_id)
    if @user.blank?
      user = Gwsub::Sb05User.new
      user.users_id = Core.user.id
      user.org_code = Core.user_group.code
      user.org_name = Core.user_group.name
      user.order "created_at DESC"
      @user = Gwsub::Sb05User.first
      if @user.blank?
        flash[:notice] = '連絡先情報が見つかりません。'
        return
      end
    end
    req = Gwsub::Sb05Request.new
    req.sb05_users_id = @user.id
    req.org_code = @user.org_code
    req.org_name = @user.org_name
    if params[:r_state]
      req.r_state = params[:r_state]
    end
    @is_get_files   = get_files
    @is_check_media = check_media
    @media_1 = @req1.m_rel
  end

  def new
    if params[:media_code].to_i == 4 && params[:cat_code].to_i == 2
      @l2_current = '01'
      @req_item = media4_cate2
     item = @req_item.id
     url = "/gwsub/sb05//sb05_requests/#{item}/edit?sb05_users_id=#{params[:sb05_users_id]}&l2_c=#{@l2_current}"
      redirect_to url
    end

    init_params
    @l2_current = '01'
     # 担当者連絡先を取得
    if params[:sb05_users_id]
      @user = Gwsub::Sb05User.find(params[:sb05_users_id])
    else
      user = Gwsub::Sb05User.new
      user.user_id = Core.user.id
      user.org_code = Core.user_group.code
      user.org_name = Core.user_group.name
      u_order = "created_at DESC"
      @user = user.find(:first,:order=>u_order)
    end
    if @user.blank? || @user==nil
      flash[:notice] = '連絡先を登録してから、依頼登録を行ってください。<br />'
#      location=@index_uri
      location="/gwsub/sb05//sb05_users/new?n_from=r"
      redirect_to location
      return
    end

    # メニュー確定までは、空表示
    if @media_code.to_i==0
      # 媒体未選択
      @req1 = Gwsub::Sb05Request.new
      return
    end
    if @categories_code.to_i==0
      # 分類未選択
      cat_count = Gwsub::Sb05MediaType.where("state=1 and media_code=#{@media_code.to_i}").count
      if cat_count == 1
        # 分類がひとつのときは確定
        @media = Gwsub::Sb05MediaType.where("state=1 and media_code=#{@media_code.to_i}").first
        @categories_code = @media.categories_code
        params[:cat_code] = @categories_code
      else
        # メニュー確定までは、空表示
        @req1 = Gwsub::Sb05Request.new
        return
      end
    end

    m_cond = "state=1 and media_code=#{@media_code.to_i} and categories_code=#{@categories_code.to_i}"
    @media = Gwsub::Sb05MediaType.where(m_cond).first
    # 新規登録画面用の初期値を取得
    if @media.blank?
      flash[:notice] = '媒体が登録されていません。'
      location=@index_uri
      redirect_to location
      return
    end

    # 新規登録画面用の記入書式を取得
#    @media_code = @media.media_code
#    @categories_code = @media.categories_code
    m_cond = "media_code='#{@media_code}' and categories_code='#{@categories_code}'"
    @notice = Gwsub::Sb05Notice.where(m_cond).first
    if @notice.blank?
      templates = nil
    else
      templates = @notice.form_templates
    end

    # 新規登録画面表示
    @req1 = Gwsub::Sb05Request.new({
        :notes_imported   => nil,
        :sb05_users_id    => @user.id ,
        :media_id         => @media.id ,
        :media_code       => @media_code,
        :categories_code  => @categories_code,
        :body1            => templates,
        :r_state          => 4,
        :m_state          => 1,
        :magazine_state   => 1,
        :mm_image_state   => '0',
        :attaches_file    => 'false'
    })
  end
  def create
    init_params
    @l2_current = '01'
#pp ['create' , params]
    @user = Gwsub::Sb05User.find(params[:req1]['sb05_users_id'])
    @req1 = Gwsub::Sb05Request.new(params[:req1])
    @media = Gwsub::Sb05MediaType.find(@req1.media_id)
    @media_code       = @media.media_code
    @categories_code  = @media.categories_code
    @req1.mm_image_state = '0' #メルマガ以外は必要ないが統一するため(メルマガ/イベント情報対策)
    # 依頼日順一覧を表示
#    location = "/gwsub/sb05//sb05_requests?v=#{@view}&sb05_users_id=#{@user.id}"
    location = "/gwsub/sb05//sb05_requests/index_created_dates"
    options = {
    :success_redirect_uri=>location,
    }
    _create(@req1,options)
  end

  def edit
    init_params
#    @l2_current = nz(params[:l2_c],@l2_current)
#    pp ['edit',params]
    # 編集対象　依頼記事
    @req1                = Gwsub::Sb05Request.find(params[:id])
    @req1.notes_imported = nil
    # 管理者以外の編集は、未確認とする
    unless @u_role==true
      @req1.m_state = 1
    end
    # 媒体マスター
    @media            = Gwsub::Sb05MediaType.find(@req1.media_id)
    @media_id         = @media.id
    @media_code       = @media.media_code
    @categories_code  = @media.categories_code
    # ヘルプ入力要領
    m_cond            = "media_code=#{@media_code} and categories_code=#{@categories_code}"
    @notice           = Gwsub::Sb05Notice.where(m_cond).first
    # 登録ユーザー
    @user             = Gwsub::Sb05User.find(@req1.sb05_users_id)
  end
  def update
    init_params
#    @l2_current = nz(params[:l2_c],@l2_current)
    @user = Gwsub::Sb05User.find(params[:req1]['sb05_users_id'])
    @req1 = Gwsub::Sb05Request.new.find(params[:id])
    @req1.attributes = params[:req1]
    @req1.mm_image_state = '0' #edit状態から解放(メルマガ/イベント情報対策)
    location = "/gwsub/sb05//sb05_requests/#{params[:id]}?sb05_users_id=#{@user.id}"
    options = {
      :success_redirect_uri=>location
    }
    @media = Gwsub::Sb05MediaType.find(@req1.media_id)
    @media_code       = @media.media_code
    @categories_code = @media.categories_code

    #edit状態から解放されたあと、画像が添付されているものについてはmm_image_state=2とする。
    item = Gwsub::Sb05File.new
    item.and :parent_id,params[:id]
    att_files = item.find(:all)
    @req1.mm_image_state ='2'     unless att_files.blank?
    @req1.attaches_file  ='true'  unless att_files.blank?

    _update(@req1,options)
  end

  def destroy
    init_params
    # 絞込み・検索条件の引継ぎ
    params1 = make_params
#    @l2_current = nz(params[:l2_c],@l2_current)
    @req1 = Gwsub::Sb05Request.find(params[:id])
    @user = Gwsub::Sb05User.find(@req1.sb05_users_id)
#    location = "/gwsub/sb05//sb05_users/#{@user.id}"
#    location = "/gwsub/sb05//sb05_requests?v=#{@view}&sb05_users_id=#{@user.id}"
    location = "/gwsub/sb05//sb05_requests/index_created_dates#{params1}"
    options = {
      :success_redirect_uri=>location,
    }
    _destroy(@req1,options)
  end

  def list
#pp ['sb05_requests/list' , params]
    # 絞込み・検索条件の引継ぎ
    params1 = make_params
    # 選択一括処理のあとの戻り先一覧
    # redirect uri
    case params[:index_type]
    when 'deafult'
      redirect_uri = "/gwsub/sb05//sb05_requests#{params1}"
    when 'dates'
      redirect_uri = "/gwsub/sb05//sb05_requests/index_created_dates#{params1}"
    when 'publish'
      redirect_uri = "/gwsub/sb05//sb05_requests/index_before_publish#{params1}"
    when 'confirm'
      redirect_uri = "/gwsub/sb05//sb05_requests/index_before_confirm#{params1}"
    else
      redirect_uri = "/gwsub/sb05//sb05_requests#{params1}"
    end
    # 確認済にする
    if !params[:finished_submit].blank?
      finished_cnt = 0
      finished_cnt_no = 0
      if params[:ids] and params[:ids].size > 0
#        ret_save = true
        for id in params[:ids]
#pp ['sb05_requests/list' , id]
          item = Gwsub::Sb05Request.find(id.to_i)
#pp ['sb05_requests/list' , item]
          if item.blank?
              finished_cnt_no += 1
          else
            if item.m_state != '2'
              item.m_state = '2'
              ret_save = item.save
              finished_cnt += 1
            else
              finished_cnt_no += 1
            end
          end
        end
        # 確認済にする
        if finished_cnt == 0
          notice_str = %Q(チェックされたデータに、未確認のデータは存在しませんでした。)
        else
          if finished_cnt_no == 0
            notice_str = "確認済にする処理が#{ret_save ? '成功' : '失敗'}しました(成功数=#{finished_cnt})。"
          else
            notice_str = "確認済にする処理が#{ret_save ? '成功' : '失敗'}しました(成功数=#{finished_cnt})。なお、すでに確認済が#{finished_cnt_no}存在しており、それらは変更しておりません。"
          end
        end
        flash[:notice] = notice_str
      else
        flash[:notice] = "対象が選択されていません"
      end
    end
#pp ['sb05_requests/list' , flash[:notice]]
    redirect_to redirect_uri
  end

  def csvput
    init_params
    @l2_current = '06'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = Gwsub::Sb05Request.all.to_csv
    send_data @item.encode(csv), filename: "sb05_requests_#{@item.encoding}.csv"
  end

  def csvup
    init_params
    @l2_current = '07'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    Gwsub::Sb05Request.transaction do
      Gwsub::Sb05Request.truncate_table
      items = Gwsub::Sb05Request.from_csv(@item.file_data)
      items.each(&:save)
    end
    flash[:notice] = '登録処理が完了しました。'
    redirect_to @index_uri
  end

  def init_params
#    flash[:notice]=''
    @s_ctl = 'r'
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb05Request.is_dev?
    @role_admin      = Gwsub::Sb05Request.is_admin?
    @u_role = @role_developer || @role_admin
    @role_edit_grp     = Core.user_group.code

    # 年度
    @fy = Gw::YearFiscalJp.get_record(Date.today)
    if @fy.blank?
      @fy = Gw::YearFiscalJp.order("start_at DESC").first
    end
    @fy_id = @fy.id

    if @u_role != true
      params[:org_id]   ? @org_id   = params[:org_id]   : @org_id   = Core.user_group.id
      if @org_id.to_i != 0
      # org_id check
        org_ids = System::GroupHistory.all.collect{|x| x.id}
        @org_id = Core.user_group.id if org_ids.index(@org_id.to_i) == nil
        org = System::GroupHistory.find(@org_id.to_i)
        @org_code = org.code
        @org_name = org.name
      else
        @org_code = nil
        @org_name = nil
      end
      @u_id     = Core.user.id
    else
      if params[:org_id]=='0'
        @org_id   = 0
        @org_code = nil
        @org_name = nil
        @u_id     = 0
      else
        unless params[:org_id].to_i==0
          @org_id   = params[:org_id]
          org_ids = System::GroupHistory.all.collect{|x| x.id}
          @org_id = Core.user_group.id if org_ids.index(@org_id.to_i) == nil
          @org = System::GroupHistory.find(@org_id.to_i)
          @org.blank? ? @org_code = nil : @org_code = @org.code
          @org.blank? ? @org_name = nil : @org_name = @org.name
          @u_id     = 0
        else
          @org_id   = 0
          @org_code = nil
          @org_name = nil
          @u_id     = 0
        end
      end
    end


    @media_code         = nz(params[:media_code],'0')
    @categories_code    = nz(params[:cat_code],'0')

    m_order = "state , media_code , categories_code"
    m_cond  = "state=1"
    m_cond += " and media_code=#{@media_code.to_i}"            unless @media_code.to_i==0
    m_cond += " and categories_code=#{@categories_code.to_i}"  unless @categories_code.to_i==0
    media_first = Gwsub::Sb05MediaType.where(m_cond).order(m_order).first
    @media_id   = nz(params[:media_id] , media_first.blank? ? 0 : media_first.id)

    @r_status     = nz(params[:r_status],0) unless @u_role==true  # 一般は公開状況すべて
    @m_status     = nz(params[:m_status],0) unless @u_role==true  # 一般は確認状況すべて
    @r_status     = nz(params[:r_status],4) if @u_role==true      # 管理者は未処理から
    @m_status     = nz(params[:m_status],1) if @u_role==true      # 管理者は未確認から
    # 表示行数　設定
    @limit = nz(params[:limit],30)
    params[:limit]      = nz(params[:limit], @limit)

    search_condition
    setting_sortkeys

    # 添付ファイル用設定
    @system = "sb05_requests"

    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current = '01'
    @l2_current = nz(params[:l2_c],'02')
    return
  end
  def search_condition
    params[:org_id]     = nz(params[:org_id],@org_id)           unless @org_id.to_i     == 0
    params[:org_code]   = nz(params[:org_code],@org_code)       unless @org_code.blank?
    params[:org_name]   = nz(params[:org_name],@org_name)       unless @org_name.blank?
#    params[:media_id]   = nz(params[:media_id],@media_id)       unless @media_id.to_i   == 0
    params[:media_code] = nz(params[:media_code],@media_code)   unless @media_code.to_i == 0
    params[:cat_code]   = nz(params[:cat_code],@categories_code)  unless @categories_code.to_i == 0
    params[:r_status]   = nz(params[:r_status],@r_status)       unless @r_status.to_i   == 0
    params[:m_status]   = nz(params[:m_status],@m_status)       unless @m_status.to_i   == 0
    qsa = ['limit', 's_keyword' ,'media_id','media_code','r_status','m_status','org_code','org_name']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sortkeys
    # default sort keys　掲載希望日・媒体・分類順
    @sort_keys = nz(params[:sort_keys], 'start_at ASC , end_at ASC , media_code ASC , categories_code ASC')
  end
  def check_media
    return true if params[:media_code].to_i == 4 && params[:cat_code].to_i == 2
  end

  # メルマガ　イベント情報　画像添付用新規データ仮登録
  def media4_cate2
    m_order               = "media_code,categories_code"
    m_cond                = "state=1 and media_code=4 and categories_code=2"
    user                  = Gwsub::Sb05User.find(params[:sb05_users_id])
    media                 = Gwsub::Sb05MediaType.new
    media.media_code      = params[:media_code] unless params[:media_code].to_i==0
    media.categories_code = params[:cat_code]   unless params[:cat_code].to_i==0
    @media                = media.find(:first,:order=>m_order,:conditions=>m_cond)
    m_cond                = "media_code='#{media.media_code}' and categories_code='#{media.categories_code}'"
    @notice               = Gwsub::Sb05Notice.where(m_cond).first
    if @notice.blank?
      templates = nil
    else
      templates = @notice.form_templates
    end
    item = Gwsub::Sb05Request.new({
        :notes_imported   => nil,
        :sb05_users_id    => user.id ,
        :media_id         => @media.id ,
        :media_code       => 4,
        :categories_code  => 2,
        :body1            => templates,
        :r_state          => 4,
        :m_state          => 1,
        :magazine_state   => 1,
        :mm_image_state   => '1',
        :attaches_file    => 'false'
    })
    item.save(:validate => false)
    return item
  end

  # メルマガ　添付画像
  def get_files
    item = Gwsub::Sb05File.new
    item.and :parent_id, @req1.id
    @items = item.find(:all)
    unless @items.length == 0
      return false
    else
      return @items
    end
  end

  #リマインダー通知：担当者→管理者
  def send_admin
    init_params
    @req1 = Gwsub::Sb05Request.find(params[:id])
    user = Gwsub::Sb05User.new
    user.and :id, @req1.sb05_users_id
    create_user = user.find(:first)

    create_user_id = create_user.user_id
    # 下書き・承認廃止に伴う変更
#    r_state_old = @req1.r_state
#    @req1.attributes = params[:item]
#    @req1.r_state = '4'
#    r_state_new = @req1.r_state
#    if (r_state_old.to_i ==1 or r_state_old.to_i ==2) and r_state_new.to_i == 3
        memo_send = Gwsub::Sb00ConferenceManager.new
        memo_send.and :controler , 'sb05_requests'
        memo_send.and :fyear_id ,  @fy_id
        memo_send.and :send_state ,  '1'
        memo_sender = memo_send.find(:all)
        options={:fr_user => create_user_id,:is_system=>1}
        memo_sender.each do |m|
          # 通知する管理者にだけ連絡メモを通知
          Gw.add_memo(m.user_id.to_s, m.memo_str, "<a href='/gwsub/sb05//sb05_requests/#{params[:id]}'>申請内容を確認してください。</a>",options)
        end
#    end
#    @req1.save
  end

  # 管理者確認ステータス
  def check_on
    # 確認済にする
    req1 = Gwsub::Sb05Request.find(params[:id])
    req1.m_state  = '2'
    req1.save(:validate => false)
    # 処理後は詳細画面に戻す
    flash[:notice]  = "確認済に更新しました。"
    location = "#{@index_uri}#{params[:id].to_s}"
    redirect_to location
  end
  def check_off
    # 未確認に戻す
    req1 = Gwsub::Sb05Request.find(params[:id])
    req1.m_state  = '1'
    req1.save(:validate => false)
    flash[:notice]  = "未確認に更新しました。"
    location = "#{@index_uri}#{params[:id].to_s}"
    redirect_to location
  end

  def make_params
    @media_code = params[:media_code]
    @r_status   = params[:r_status]
    @org_id     = params[:org_id]
    @m_status   = params[:m_status]
    @limit      = params[:limit]
#{hidden_field_tag('s_keyword', params[:s_keyword])}
    params1 = "?media_code=#{@media_code}"
    params1 += "&r_status=#{@r_status}"
    params1 += "&org_id=#{@org_id}"
    params1 += "&m_status=#{@m_status}"
    params1 += "&limit=#{@limit}"
    params1 += "&s_keyword=#{params[:s_keyword]}"
    return params1
  end
end
