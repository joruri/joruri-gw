class Gwsub::Admin::Sb05::Sb05RequestsPutController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
#    pp ['initialize',params]

    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "広報依頼"
  end

#  def index
#    init_params
#    order = "media_code ASC,start_at ASC"
#    cond = "r_state=3"
#    request = Gwsub::Sb05Request.find(:first,:conditions=>cond,:order=>order)
#    @start_at = request.start_at
#    @media    = Gwsub::Sb05MediaType.find(request.media_id)
#  end

  def finished
    init_params
    return error_auth unless @u_role==true

    @l2_current='02'

    order = "media_code ASC,start_at ASC"
    cond = "r_state=4 and start_at IS NOT NULL"
    request = Gwsub::Sb05Request.where(cond).order(order)
    if request.blank?
      return flash[:notice]="対象がありません。"
    end
    @start_at = request.start_at
    @media    = Gwsub::Sb05MediaType.find(request.media_id)

    return if params[:item].nil?
    par_item = params[:item]
#    e_flg = true
    if par_item[:start_date].blank?
      flash[:notice] = "対象日を指定してください。"
      return
    end
    case par_item[:state]
    when 'finished'
      count_n = 0
      count_e = 0
      item1 = Gwsub::Sb05Request.new
      item1.r_state    = par_item[:r_status]
      item1.media_code = par_item[:media_code]
      item1.start_at   = par_item[:start_date]
      item1.order "media_code ASC , start_at ASC , created_at ASC"
      items = item1.find(:all)
      items.each do |item|
        item.r_state = 5
        item.notes_imported = nil
        if item.save
          count_n = count_n+1
        else
          count_e = count_e+1
#          e_flg = false
        end
      end unless items.blank?
#      flash[:notice] = "更新に失敗しました。"      if     e_flg == false
#      flash[:notice] = "更新しました。"            unless e_flg == false
      flash[:notice] = "#{count_n}件を処理済にしました。" if count_n > 0
      flash[:notice] = flash[:notice]||"#{count_e}件のエラーがありました。" if count_e > 0
      flash[:notice] = "更新対象が０件でした。"    if items.blank?
    else
      flash[:notice] = "パラメーター不正のため、処理済にする処理をスキップしました。"
    end
  end

  def csvput
    init_params
    return error_auth unless @u_role==true

    @l2_current='01'

    # 初期表示
    # 媒体・基準日
    order = "media_code ASC,base_at ASC"
    # 確認済・未処理
    cond = "m_state=2 and r_state=#{@r_status.to_i} and start_at IS NOT NULL and base_at IS NOT NULL"
    request = Gwsub::Sb05Request.where(cond).order(order).first
    if request.blank?
      return flash[:notice]="対象がありません。"
    end
    @base_at = request.base_at
    @media    = Gwsub::Sb05MediaType.find(request.media_id)

    return if params[:item].nil?
    par_item = params[:item]
    #raise TypeError
    nkf_options = case par_item[:nkf]
        when 'utf8'
          '-w'
        when 'sjis'
          '-s'
        end
    case par_item[:csv]
    when 'put'
      if par_item[:b_at].blank?
        flash[:notice] = "対象日を指定してください。"
        return
      end
      m_cond = "state=1 and media_code=#{par_item[:media_code]}"
      @media = Gwsub::Sb05MediaType.where(m_cond).first
#      filename = "sb05_requests_select_#{par_item[:nkf]}.csv"
      filename = "広報原稿_#{@media.media_name}_#{par_item[:b_at]}_#{par_item[:nkf]}.csv"
      order = "start_at ASC,media_code ASC,categories_code ASC"
      cond = set_condition(par_item)
      # 出力項目指定
      cols = par_item[:chks].to_a.sort
      sel_cols = cols.join(',')
      select = "title,body1"
      select += ",#{sel_cols}" if !sel_cols.blank?
      # 出力データ抽出
      items = Gwsub::Sb05Request.where(cond).order(order).select(select)
      if items.blank?
      else
        file = Gw::Script::Tool.ar_to_csv(items, :cols=>select)
        send_data NKF::nkf(nkf_options,file), :filename => filename
      end
    else
    end
  end
  def set_condition(param)
    conditions = ""
    conditions << "m_state='2'"
    conditions << " and r_state='#{param[:r_status]}'"
    conditions << " and media_code=#{param[:media_code]}"
    conditions << " and base_at='#{param[:b_at]}'"
    return conditions
  end

  def start_fields
    base_dates = Gwsub::Sb05Request.select_dd_base_dates(nil, 2, params[:r_status], params[:media_cd])
    render text: view_context.options_for_select(base_dates), layout: false
  end

  def init_params
    @s_ctl = 'r'
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb05Request.is_dev?
    @role_admin      = Gwsub::Sb05Request.is_admin?
    @u_role = @role_developer || @role_admin
    @role_editor     = Core.user_group.code

    # 表示条件設定
    # 絞り込み媒体
    @media_code   = nz(params[:media_code],1)
    # 基準日
    @base_at      = nz(params[:b_at],'0')
    # 確認済
    @m_status     = nz(params[:m_status],2)
    # 未処理
    @r_status     = nz(params[:r_status],4)
    # 表示行数　設定
    @limit = nz(params[:limit],30)
    params[:limit]      = nz(params[:limit], @limit)

    search_condition
    setting_sortkeys
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current='03'
    @l2_current='01'
    return
  end
  def search_condition
    params[:b_at]       = nz(params[:b_at],@base_at)
    params[:media_code] = nz(params[:media_code],@media_code)
    params[:m_status]   = nz(params[:m_status],@m_status)
    params[:r_status]   = nz(params[:r_status],@r_status)
    qsa = ['limit', 's_keyword' ,'media_code' , 'b_at' , 'm_state' , 'r_status' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sortkeys
    @sort_keys = nz(params[:sort_keys], 'media_code ASC , base_at ASC , start_at ASC , created_at ASC')
  end

end
