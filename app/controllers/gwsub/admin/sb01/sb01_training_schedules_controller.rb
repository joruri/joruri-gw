class Gwsub::Admin::Sb01::Sb01TrainingSchedulesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  layout "admin/template/sb01_training"

  def pre_dispatch
    Page.title = "研修申込・受付"
    @public_uri = "/gwsub/sb01/sb01_training_schedules"
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    init_params
    @item1 = Gwsub::Sb01Training.find(@t_id)
    item = Gwsub::Sb01TrainingSchedule.new
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end

  def show
    init_params
    @item1 = Gwsub::Sb01Training.find(@t_id)
    @item = Gwsub::Sb01TrainingSchedule.find(params[:id])
    @p_id = @item.id
  end

  def new
    init_params
    @item = Gwsub::Sb01TrainingSchedule.new({
        :state => '1'
      })
  end

  def create
    init_params
    new_item = Gwsub::Sb01TrainingSchedule.set_f(params[:item])
    @item = Gwsub::Sb01TrainingSchedule.new(new_item)
    location = @public_uri
    options = {
      :success_redirect_uri=>location,
    }
    _create(@item,options)
  end

  def edit
    init_params
    @item = Gwsub::Sb01TrainingSchedule.find(params[:id])
    @item1 = Gwsub::Sb01Training.find(@item.training_id)
  end

  def update
    init_params
    @item = Gwsub::Sb01TrainingSchedule.find(params[:id])
    @trainig = Gwsub::Sb01Training.where(:id =>@item.training_id).first
    @item1 = @trainig
    case @trainig.state
      # 研修のstateに対応する開催日ごとのstateを強制設定
    when '1'
      # 準備中
      params[:item]['state']='1'
    when '2'
      # 受付中の場合は、開催日個別のstateをそのまま採用
      # 「研修全体として受付中・開催日個別で準備中」も許容する。
    when '3'
      # 締切
      params[:item]['state']='3'
    when '4'
      # 終了
      params[:item]['state']='4'
    else
    end

    st_at     = @item.from_start.strftime('%Y-%m-%d ')
    st_at    += params[:item]['st_time']
    st_at    += ":#{params[:item]['st_time_min']}"
    ed_at     = @item.from_end.strftime('%Y-%m-%d ')
    ed_at    += params[:item]['ed_time']
    ed_at    += ":#{params[:item]['ed_time_min']}"
    params[:item].delete 'st_time'
    params[:item].delete 'st_time_min'
    params[:item].delete 'ed_time'
    params[:item].delete 'ed_time_min'
    @item.attributes = params[:item]
    @item.from_start = st_at
    @item.from_end   = ed_at
    location = "#{@public_uri}/#{@item.id}?t_id=#{@item.training_id}&t_menu=plans"
    after_process = Proc.new{
      gw_skd = Gw::Schedule.where(:id =>@item.schedule_id).first
      unless gw_skd.blank?
        gw_skd.st_at = @item.from_start
        gw_skd.ed_at = @item.from_end
        gw_skd.place = @item.prop_name
        gw_skd.save
      end
      skd_m = Gwsub::Sb01TrainingScheduleMember.where("training_schedule_id = #{@item.id}")
      unless skd_m.blank?
        skd_m.each do |s|
          gw_skd_m = Gw::Schedule.where(:id =>s.schedule_id).first
          unless gw_skd_m.blank?
            gw_skd_m.st_at = @item.from_start
            gw_skd_m.ed_at = @item.from_end
            gw_skd_m.place = @item.prop_name
            gw_skd_m.save
          end
        end
      end
      if @item.state == '3'
        if @item.members_max > @item.members_current
          skd_cond = Gwsub::Sb01TrainingSchedule.where(:id =>@item.id).first
          skd_cond.state = '2'
          skd_cond.save
        end
      end
    }
    options = {
      :after_process => after_process,
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

  def destroy
    init_params
    @item = Gwsub::Sb01TrainingSchedule.find(params[:id])
    location = "/gwsub/sb01/sb01_training_plans/#{@item.training.id}"
    after_process = Proc.new{
        skd = Gw::Schedule.where(:id =>@item.schedule_id).first
        skd.destroy unless skd.blank?
        destroy_members_shcedule
      }
    options = {
      :after_process => after_process,
      :success_redirect_uri=>location
    }
    _destroy(@item,options)
  end

  def destroy_members_shcedule
    skd_m = Gwsub::Sb01TrainingScheduleMember.where("training_schedule_id = #{@item.id}")
    unless skd_m.blank?
      skd_m.each do |s|
        skd = Gw::Schedule.where(:id =>s.schedule_id).first
        skd.destroy unless skd.blank?
        s.destroy
      end
      #Gwsub::Sb01TrainingSchedule.destroy_all("training_schedule_id = #{@item.id}")
    end
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb01Training.is_dev?
    @role_admin      = Gwsub::Sb01Training.is_admin?
    @u_role = @role_developer || @role_admin

    # 表示行数　設定
    @limits = nz(params[:limit],30)
    # 研修id
    @t_id_top = Gwsub::Sb01Training.order("fyear_markjp DESC").first
    @t_id = nz(params[:t_id],@t_id_top.id)
    # 経路
    @top_menu = nz(params[:t_menu],'entries')
    case @top_menu
    when 'plans'
      @menu_title = "企画・設定"
    else
      @menu_title = "検索・申込"
    end
    # 表示形式
    @v = nz(params[:v],1)

    @bbs_link_title  = '別ウィンドウ・別タブで案内記事を開きます'

    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    case @top_menu
    when 'plans'
      @l1_current=nz(params[:l1_c],'02')
      @l2_current=nz(params[:l2_c],'02')
    when 'entries'
      @l1_current=nz(params[:l1_c],'01')
      @l2_current=nz(params[:l2_c],'02')
    else
      @l1_current=nil
    end
  end

  def search_condition
    params[:l1_c]     = nz(params[:l1_c],@l1_current)
    params[:l2_c]     = nz(params[:l2_c],@l2_current)
    params[:t_id]     =nz(params[:t_id],@t_id)
    params[:t_menu]   =nz(params[:t_menu],@top_menu)
    params[:limit]    = nz(params[:limit], @limits)

    qsa = ['limit' , 's_keyword' , 't_id' , 'p_id' ,'m_id' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'from_start' )
  end

  def closed
    init_params
    @item = Gwsub::Sb01TrainingSchedule.find(params[:id])
    case @item.state
    when '2'
      @item.state = '3'
    when '3'
      @item.state = '2'
      change_training_condition('2')
    else
    end
    location = "#{@public_uri}/#{@item.id}?t_id=#{@t_id}&t_menu=#{@top_menu}"
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

  def prepared
    init_params
    @item = Gwsub::Sb01TrainingSchedule.find(params[:id])
    case @item.state
    when '1'
      @item.state = '2'
    when '2'
      @item.state = '1'
      #スケジュールがすべて「準備中」の場合は研修本体も「準備中に」
    else
    end
    location = "#{@public_uri}/#{@item.id}?t_id=#{@t_id}&t_menu=#{@top_menu}"
    after_process = Proc.new{
      if @item.state == '1'
        #準備中に戻したとき、すべての日程が「準備中」なら研修本体のステータスも準備中に
        ts_conditions   = Gwsub::Sb01TrainingSchedule.where("training_id = #{@item.training_id}").count
        ts_preparations = Gwsub::Sb01TrainingSchedule.where("training_id = #{@item.training_id} and state = '1'").count
        if ts_conditions == ts_preparations
          change_training_condition('1')
        end
      elsif @item.state == '2'
        #受付中にしたときは、研修本体のステータスも受付中にする
         change_training_condition('2')
      end
      }
    options = {
      :success_redirect_uri=>location,
      :after_process       =>after_process
    }
    _update(@item,options)
  end

  def change_training_condition(state)
    training = Gwsub::Sb01Training.new
    @training = training.find(@item.training_id)
    @training.state = state
    @training.save
  end

  def csvput
    training = Gwsub::Sb01Training.find_by(id: params[:t_id])
    skd      = Gwsub::Sb01TrainingSchedule.find_by(id: params[:p_id])

    members = Gwsub::Sb01TrainingScheduleMember.where(training_schedule_id: params[:p_id])
    if members.blank? || training.blank? ||skd.blank?
      return redirect_to "@{public_uri}/?t_id=#{params[:t_id]}&t_menu=entries"
    end
    csv = members.to_csv(headers: ["職員番号","役職","受講者名","受講者所属コード","受講者所属","受講者連絡先","メールアドレス","申込者","申込者所属","申込者連絡先"]) do |item|
      data = []
      data << item.user_rel1.try(:code)
      data << item.user_rel1.try(:official_position)
      data << item.user_rel1.try(:name)
      data << item.group_rel1.try(:code)
      data << item.group_rel1.try(:name)
      data << item.training_user_tel
      data << item.user_rel1.try(:email)
      data << item.user_rel2.try(:name)
      data << item.group_rel2.try(:name)
      data << item.entry_user_tel
      data
    end

    filename = "名簿_#{training.title}_#{skd.from_start.strftime('%Y年%m月%d日')}.csv"
    send_data NKF::nkf('-s', csv), type: 'text/csv', filename: filename
  end
end
