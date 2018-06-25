class Gwsub::Admin::Sb05::Sb05DesiredDatesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch

    return redirect_to(url_for(action: :index)) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "広報依頼"
  end

  def index
    init_params
    return error_auth unless @u_role==true

    if params[:m]=='clr'
      Gwsub::Sb05DesiredDate.truncate_table
    end
    item = Gwsub::Sb05DesiredDate.new
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end
  def show
    init_params
    return error_auth unless @u_role==true

    @item = Gwsub::Sb05DesiredDate.find(params[:id])
  end

  def new
    init_params
    return error_auth unless @u_role==true

    @l2_current ='01'
    @item = Gwsub::Sb05DesiredDate.new
  end
  def create
    init_params
    return error_auth unless @u_role==true

    @item = Gwsub::Sb05DesiredDate.new(params[:item])
    location = @index_uri
    _create(@item,:success_redirect_uri=>location)
  end

  def edit
    init_params
    return error_auth unless @u_role==true

#    pp ['edit',params]
    @item = Gwsub::Sb05DesiredDate.find(params[:id])
  end
  def update
    init_params
    return error_auth unless @u_role==true

    @item = Gwsub::Sb05DesiredDate.new.find(params[:id])
    @item.attributes = params[:item]
    location = @index_uri
    _update(@item,:success_redirect_uri=>location)
  end

  def destroy
    init_params
    return error_auth unless @u_role==true

    @item = Gwsub::Sb05DesiredDate.find(params[:id])
    location = @index_uri
    _destroy(@item,:success_redirect_uri=>location)
  end

  def making
    init_params
    return error_auth unless @u_role==true

    @l2_current ='03'
#pp ['making',params]
#    m_cond="media_code='1' || media_code='4'"
    m_order = "media_code,categories_code"
    @media = Gwsub::Sb05MediaType.order(m_order).first
    return if params[:item].nil?

    par_item = params[:item]
    m_cd = par_item[:m_cd]
    m_cond="media_code='#{m_cd}'"
    m_order = "media_code,categories_code"
    media = Gwsub::Sb05MediaType.where(m_cond).order(m_order).first
    return if media.blank?

    if par_item[:chks1].blank? ||
      par_item[:chks2].blank? ||
      par_item[:range_start_at].blank? ||
      par_item[:range_end_at].blank?
      flash[:notice] = flash[:notice] + '<br />週を指定してください' if par_item[:chks1].blank?
      flash[:notice] = flash[:notice] + '<br />曜日を指定してください' if par_item[:chks2].blank?
      flash[:notice] = flash[:notice] + '<br />期間開始日を指定してください' if par_item[:range_start_at].blank?
      flash[:notice] = flash[:notice] + '<br />期間終了日を指定してください' if par_item[:range_end_at].blank?
      return
    end
    monthly = par_item[:chks1].to_a.sort.collect{|k,v| v}
    weekday = par_item[:chks2].to_a.sort.collect{|k,v| v}
    start_at = Gw.get_parsed_date(par_item[:range_start_at])
    end_at = Gw.get_parsed_date(par_item[:range_end_at])
    work_day = start_at

    while work_day <= end_at
      check_day = Gw.get_parsed_date(work_day)
      if check_day.blank?
        # 日付チェックでエラーの時は次へ
        work_day = work_day + 24*60*60
        next
      end
      w = work_day.wday
      # 曜日が対象外の場合は、次の日付へ
      if weekday.index(w.to_s)== nil
        work_day = work_day + 24*60*60
        next
      end
      # 週チェック
      case work_day.day
        when 1..7
          if monthly.index('1')==nil
          else
            save_item(media.id,m_cd,work_day,w,'1')
          end
        when 8..14
          if monthly.index('2')==nil
          else
            save_item(media.id,m_cd,work_day,w,'2')
          end
        when 15..21
          if monthly.index('3')==nil
          else
            save_item(media.id,m_cd,work_day,w,'3')
          end
        when 22..28
          if monthly.index('4')==nil
          else
            save_item(media.id,m_cd,work_day,w,'4')
          end
        else
          if monthly.index('5')==nil
          else
            save_item(media.id,m_cd,work_day,w,'5')
          end
      end
        work_day = work_day + 24*60*60
    end
    location = @index_uri
    redirect_to location
  end
  def save_item(id,code,date,weekday,monthly)
    item = Gwsub::Sb05DesiredDate.new({
#      :media_id => id,
      :media_code => code,
      :desired_at => date
#      :desired_at => date,
#      :weekday => weekday,
#      :monthly => monthly
    })
    # 登録でエラーは無視
    if item.save
    else
#      pp item
    end
  end

  def csvput
    init_params
    return error_auth unless @u_role==true

    @l2_current ='05'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = Gwsub::Sb05DesiredDate.all.to_csv
    send_data @item.encode(csv), filename: "sb05_desired_dates_#{@item.encoding}.csv"
  end

  def csvup
    init_params
    return error_auth unless @u_role==true

    @l2_current ='06'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    Gwsub::Sb05DesiredDate.transaction do
      Gwsub::Sb05DesiredDate.truncate_table
      items = Gwsub::Sb05DesiredDate.from_csv(@item.file_data)
      items.each(&:save)
    end
    flash[:notice] = '登録処理が完了しました。'
    redirect_to @index_uri
  end

  def init_params
    flash[:notice]=''
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb05Request.is_dev?
    @role_admin      = Gwsub::Sb05Request.is_admin?
    @u_role = @role_developer || @role_admin
    @role_editor     = Core.user_group.code

    m_order = "media_code,categories_code"
    @media = Gwsub::Sb05MediaType.order(m_order).first

    # 表示条件設定
    @m_id     = nz(params[:m_id],0)
    @m_cd     = nz(params[:m_cd],0)
    # 表示行数　設定
    @limit = nz(params[:limit],30)
    params[:limit]      = nz(params[:limit], @limit)

    search_condition
    setting_sortkeys
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current ='06'
    @l2_current ='02'
    return
  end
  def search_condition
    params[:m_id]   = nz(params[:m_id],@m_id)
    params[:m_cd]   = nz(params[:m_cd],@m_cd)
    qsa = ['limit', 's_keyword' ,'m_id' ,'m_cd' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sortkeys
    @sort_keys = nz(params[:sort_keys], 'media_code , desired_at DESC')
  end

end
