class Gwsub::Admin::Sb05::Sb05DesiredDateConditionsController < Gw::Controller::Admin::Base
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

    item = Gwsub::Sb05DesiredDateCondition.new
    item.page   params[:page], params[:limit]
    order = "media_id , st_at dESC"
    @items = item.find(:all , :order=>order)
  end

  def show
    init_params
    return error_auth unless @u_role==true

    @item = Gwsub::Sb05DesiredDateCondition.find(params[:id])
  end

  def new
    init_params
    return error_auth unless @u_role==true

    @l2_current ='01'
    @item = Gwsub::Sb05DesiredDateCondition.new
    @item.media_id = @media.id
  end
  def create
    init_params
    return error_auth unless @u_role==true

    @l2_current ='01'
    @item = Gwsub::Sb05DesiredDateCondition.new(params[:item])
    location = @index_uri
    _create(@item,:success_redirect_uri=>location)
  end

  def edit
    init_params
    return error_auth unless @u_role==true

    @item = Gwsub::Sb05DesiredDateCondition.find(params[:id])
  end
  def update
    init_params
    return error_auth unless @u_role==true

    @item = Gwsub::Sb05DesiredDateCondition.find(params[:id])
    @item.attributes = params[:item]
    location = @index_uri
    _update(@item,:success_redirect_uri=>location)
  end

  def destroy
    init_params
    return error_auth unless @u_role==true

    @item = Gwsub::Sb05DesiredDateCondition.find(params[:id])
    location = @index_uri
    _destroy(@item,:success_redirect_uri=>location)
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb05Request.is_dev?
    @role_admin      = Gwsub::Sb05Request.is_admin?
    @u_role = @role_developer || @role_admin
    @role_editor     = Core.user_group.code

    m_order = "media_code,categories_code"
    @media = Gwsub::Sb05MediaType.order(m_order).first

    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current ='06'
    @l2_current ='02'
    return
  end

  def expand_date
    init_params
    return error_auth unless @u_role==true

    condition = Gwsub::Sb05DesiredDateCondition.where(:id =>params[:id]).first
    media = Gwsub::Sb05MediaType.where(:id => condition.media_id.to_i).first
    return flash[:notice] = "対象の媒体が設定されていません。" if media.blank?

    m_cd = media.media_code
    # 日付展開
    @count_dates =[0,0]
    monthly = [condition.w1,condition.w2,condition.w3,condition.w4,condition.w5]
    weekday = [condition.d0,condition.d1,condition.d2,condition.d3,condition.d4,condition.d5,condition.d6]
    start_at = Gw.get_parsed_date(condition.st_at)
    end_at = Gw.get_parsed_date(condition.ed_at)
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
      if weekday[w.to_i]!=true
        work_day = work_day + 24*60*60
        next
      end
      # 週チェック
      case work_day.day
        when 1..7
          if monthly[0]==true
            save_item(media.id,m_cd,work_day,w,'1')
          end
        when 8..14
          if monthly[1]==true
            save_item(media.id,m_cd,work_day,w,'2')
          end
        when 15..21
          if monthly[2]==true
            save_item(media.id,m_cd,work_day,w,'3')
          end
        when 22..28
          if monthly[3]==true
            save_item(media.id,m_cd,work_day,w,'4')
          end
        else
          if monthly[4]==true
            save_item(media.id,m_cd,work_day,w,'5')
          end
      end
        work_day = work_day + 24*60*60
    end
    flash[:notice] = "指定の期間で、#{@count_dates[0].to_s}件登録しました。"
    location = @index_uri
    redirect_to location
  end

  def save_item(id,code,date,weekday,monthly)
    item = Gwsub::Sb05DesiredDate.new({
      :media_id => id,
      :media_code => code,
      :desired_at => date,
      :weekday => weekday,
      :monthly => monthly
    })
    # 登録でエラーは無視
    if item.save
      @count_dates[0] = @count_dates[0] + 1
    else
      @count_dates[1] = @count_dates[1] + 1
    end
  end
end
