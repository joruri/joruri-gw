class Gwsub::Admin::Sb01::Sb01TrainingPlansController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  layout "admin/template/sb01_training"

  def pre_dispatch
   Page.title = "研修申込・受付"
   @public_uri = "/gwsub/sb01/sb01_training_plans"
  end

  def index
    init_params
    item = Gwsub::Sb01Training.new
    item.search params
#    item.creator
    item.page   params[:page], params[:limit]
    item.order @sort_keys, 'id ASC'
    @items = item.find(:all)
    _index @items
  end

  def show
    init_params
    @l2_current=nz(params[:l1_c],'02')
    @item = Gwsub::Sb01Training.find(params[:id])
    # 開催予定日取得
    @ts = Gwsub::Sb01TrainingSchedule.where(:training_id => @item.id).order(:from_start)
    #受講者が登録されている場合は準備中に戻せない
    @preparable = true
    unless @ts.blank?
      @ts.each do |ts|
        @preparable = false if ts.members.size != 0
      end
    end
    @editor_role = Gwsub::Sb01Training.is_editor?(@item.group_code.slice(0,6),Core.user_group.code)
    @docs_editor = @editor_role || @u_role
    # 予約条件取得
    @tcs = Gwsub::Sb01TrainingScheduleCondition.where(:training_id => @item.id).order(:from_start)
    #最終開催日が過ぎているか判定
    @skd = Gwsub::Sb01TrainingSchedule.where('training_id = ?', @item.id).order('IF( ISNULL( from_start ) , 1, 0 ) ASC , from_start DESC').first
    @expiry = false
    @expiry = true if @skd.from_start < Time.now and @item.state == '2' if !@skd.blank? && !@skd.from_start.blank?
  end

  def new
    init_params
    @l2_current=nz(params[:l1_c],'01')
    @item = Gwsub::Sb01Training.new
    @item.fyear_id    = @fyed_id
    @item.categories  = @cat
    @item.state       = '1'
    @item.group_id     = Core.user_group.id
    @item.id = create_kari_id()
  end

  #添付ファイルUpload用に仮の研修IDを発行する
  def get_kari_id()
    if session[:sb01_training_plans_kari_id].nil?
      create_kari_id()
    end
    return session[:sb01_training_plans_kari_id]
  end

  #仮の研修IDの設定
  def set_kari_id(id)
    return session[:sb01_training_plans_kari_id] = id
  end

  #仮の研修IDを破棄する
  def flush_kari_id()
    return set_kari_id(nil)
  end

  #仮の研修IDの生成
  def create_kari_id()
    #新規作成時、添付ファイル用に仮のIDを設定しておく
    return set_kari_id(Gwsub::Sb01TrainingFile::create_kari_id())
  end

  def create
    init_params
    _kari_id = get_kari_id()

    new_item = Gwsub::Sb01Training.set_f(plan_params)
    @item = Gwsub::Sb01Training.new(new_item)
    @cat = @item.categories
    @fyed_id = @item.fyear_id

    @dest_folder_name = ""
    if @item.save
      #仮IDを設定していたUploadファイルに対して本IDを設定
      flush_kari_id()
      attached_files = Gwsub::Sb01TrainingFile.where(:parent_id => _kari_id)
      attached_files.each do | af |
        af.move_parent_path(@item.id)
        af.update_attribute(:parent_id, @item.id)
        @dest_folder_name = af.parent_folder_name if @dest_folder_name == ""
      end

      #書き換えた親フォルダ名で本文を修正
      _body = @item.body.gsub(/\/#{_kari_id}\//, '/'+@dest_folder_name.to_s+'/')
      @item.update_attribute(:body, _body)

      create_or_update_bbsdoc(@item)

      location = "#{@public_uri}/#{@item.id}"
      redirect_to location
    else
      @item.id = get_kari_id()
      render :action=>:new
    end
  end

  def create_or_update_bbsdoc(item)
    #掲示板設定があれば記事を作成

    bbs_title_id = Gwsub::Property::TrainingBoard.first_or_new.board_id
    if bbs_title_id
      title = Gwbbs::Control.where(:id => bbs_title_id, :state => 'public').first
      if title
        mode = nil
        if item.bbs_doc_id
          bbs_doc = item.get_bbs_item(title.id) || Gwbbs::Doc.new
        else
          bbs_doc = Gwbbs::Doc.new
        end
        expiry_date = Time.now + 24*60*60
        bbs_doc.attributes = {
          :state => 'preparation',
          :title_id => title.id,
          :latest_updated_at => Time.now,
          :importance=> 1,
          :one_line_note => 0,
          :title => item.title,
          :body => item.body,
          :section_code => item.group_code,
          :category4_id => 0,
          :able_date => Time.now.strftime("%Y-%m-%d"),
          :expiry_date => expiry_date.strftime("%Y-%m-%d"),
        }
        bbs_doc.save(:validate => false)
         unless bbs_doc.blank?
           Gwsub::Sb01Training.where(:id => @item.id).update_all(:bbs_doc_id => bbs_doc.id, :bbs_url => "/gwbbs/docs/#{bbs_doc.id}?title_id=#{title.id}&limit=20&state=GROUP")
         end
      end
    end
  end

  def edit
    init_params
    @item = Gwsub::Sb01Training.find(params[:id])
    @cat = @item.categories
    @fyed_id = @item.fyear_id
  end

  def update
    init_params
    @item = Gwsub::Sb01Training.find(params[:id])
    new_item = Gwsub::Sb01Training.set_f(plan_params)
    @item.attributes = new_item
    @fyed_id = params[:item]['fyear_id']
    location = "#{@public_uri}/#{@item.id}"
    options = {
      :success_redirect_uri=>location,
      :after_process=>Proc.new{
      update_schedule_title
      update_members_shcedule_title
      create_or_update_bbsdoc(@item)
    }}
    _update(@item,options)
  end

  def update_schedule_title
    t_skd = Gwsub::Sb01TrainingSchedule.where("training_id = #{@item.id}")
    unless t_skd.blank?
      t_skd.each do |t|
        skd = Gw::Schedule.where(:id => t.schedule_id).first
        unless skd.blank?
          skd.title = @item.title
          skd.updater_uid   = @item.member_id
          skd.updater_ucode = @item.member_code
          skd.updater_uname = @item.member_name
          skd.updater_gid   = @item.group_id
          skd.updater_gcode = @item.group_code
          skd.updater_gname = @item.group_name
          skd.inquire_to    = @item.member_tel
          skd.save
        end
      end
    end
  end

  def update_members_shcedule_title
    skd_m = Gwsub::Sb01TrainingScheduleMember.where("training_id = #{@item.id}")
    unless skd_m.blank?
      skd_m.each do |m|
        skd = Gw::Schedule.where(:id =>m.schedule_id).first
        unless skd.blank?
          skd.title = @item.title
          skd.updater_uid   = @item.member_id
          skd.updater_ucode = @item.member_code
          skd.updater_uname = @item.member_name
          skd.updater_gid   = @item.group_id
          skd.updater_gcode = @item.group_code
          skd.updater_gname = @item.group_name
          skd.save
        end
      end
    end
  end

  def destroy
    init_params
    @item = Gwsub::Sb01Training.find(params[:id])
    location = "/gwsub/sb01/sb01_training_plans"
    after_process = Proc.new{
        @item.class.delay.destroy_relation_items(@item.id)
      }
    options = {
      :success_redirect_uri=>location,
      :after_process       =>after_process
    }
    _destroy(@item,options)
  end

  def site_url
    @site_url = url_for(:action => 'index' )
    @site_url.sub!(url_for(:action => 'index', :only_path => true).split(/\//).pop, '')
    @site_url.chop! if @site_url[-1, 1] == '/'
  end

  def init_params

    # ユーザー権限設定
    @role_developer  = Gwsub::Sb01Training.is_dev?
    @role_admin      = Gwsub::Sb01Training.is_admin?
    @u_role = @role_developer || @role_admin

    # 管理者以外は自所属のみ表示
    if @u_role==true
      @g_id = 0
    else
      @g_id = Core.user_group.id
    end
    # 対象年度　設定
    @fyed_id_today = Gw::YearFiscalJp.get_record(Date.today).id
    @fyed_id = nz(params[:fyed_id],@fyed_id_today)
    # 表示行数　設定
    @limits = nz(params[:limit],30)
    # 掲示板分類
    # catgories : 掲示板分類（1:研修一覧・2:受講者向け利用方法・3:企画者向け利用方法）
    @cat = '1'
    @menu_title = "企画・設定"

    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current=nz(params[:l1_c],'02')
    @l2_current=nz(params[:l2_c],'02')
  end

  def search_condition
    params[:l1_c]     = nz(params[:l1_c],@l1_current)
    params[:l2_c]     = nz(params[:l2_c],@l2_current)
    params[:g_id]     = nz(params[:g_id],@g_id)
    params[:limit]    = nz(params[:limit], @limits)

    qsa = ['limit' ,'g_id']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'fyear_markjp DESC , categories ASC , updated_at DESC' )
  end

  def user_fields
    users = System::User.get_user_select(params[:g_id])
    render text: view_context.options_for_select([['[指定なし]','']] + users), layout: false
  end

  def closed
    init_params
    @item = Gwsub::Sb01Training.new.find(params[:id])
    case @item.state
    when '2'
      @item.state = '3'
      Gwsub::Sb01TrainingSchedule.where("training_id=#{@item.id}").update_all("state='3'")
    when '3'
      @item.state = '2'
      Gwsub::Sb01TrainingSchedule.where("training_id=#{@item.id}").update_all("state='2'")
    else
    end
    location = "#{@public_uri}/#{@item.id}"
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

  def prepared
    init_params
    @item = Gwsub::Sb01Training.new.find(params[:id])
    case @item.state
    when '1'
      @item.state = '2'
      Gwsub::Sb01TrainingSchedule.where("training_id=#{@item.id}").update_all("state='2'")
      bbs_title_id = Gwsub::Property::TrainingBoard.first_or_new.board_id
      bbs_doc_item = @item.get_bbs_item(bbs_title_id)
      unless  bbs_doc_item.blank?
        bbs_doc_item.state = "public"
        bbs_doc_item.save(:validate => false)
      end
    when '2'
      @item.state = '1'
      Gwsub::Sb01TrainingSchedule.where("training_id=#{@item.id}").update_all("state='1'")
    else
  end
    location = "#{@public_uri}/#{@item.id}"
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

  def expired
    init_params
    @item = Gwsub::Sb01Training.new.find(params[:id])
    @item.state = '4'
    Gwsub::Sb01TrainingSchedule.where("training_id=#{@item.id}").update_all("state='4'")
    location = "#{@public_uri}/#{@item.id}"
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

private

  def plan_params
    params.require(:item).permit(:fyear_id, :fyear_markjp, :categories, :state, :bbs_doc_id, :bbs_url,
      :title, :body, :group_id, :member_id, :member_tel)
  end

end
