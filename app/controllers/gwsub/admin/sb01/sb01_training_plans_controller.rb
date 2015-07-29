# -*- encoding: utf-8 -*-
class Gwsub::Admin::Sb01::Sb01TrainingPlansController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::SortKey
  include Gwboard::Controller::Authorize

  layout "admin/template/sb01_training"

  def pre_dispatch
   Page.title = "研修申込・受付"
   @public_uri = "/gwsub/sb01/sb01_training_plans"
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    init_params
    item = Gwsub::Sb01Training.new
    item.search params
#    item.creator
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end

  def show
    init_params
    @l2_current=nz(params[:l1_c],'02')
    @item = Gwsub::Sb01Training.find(params[:id])
    # 開催予定日取得
    ts = Gwsub::Sb01TrainingSchedule.new
    @ts = ts.find(:all,
      :conditions => ['training_id = ? ', @item.id],
      :order => 'from_start ASC'
    )
  end

  def new
    init_params
    @l2_current=nz(params[:l1_c],'01')
    @item = Gwsub::Sb01Training.new
    @item.fyear_id    = @fyed_id
    @item.categories  = @cat
    @item.state       = '1'
    @item.group_id     = Site.user_group.id
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
    
    new_item = Gwsub::Sb01Training.set_f(params[:item])
    @item = Gwsub::Sb01Training.new(new_item)
    @cat = @item.categories
    @fyed_id = @item.fyear_id

    @dest_folder_name = ""
    if @item.save
      #仮IDを設定していたUploadファイルに対して本IDを設定
      flush_kari_id()
      attached_files = Gwsub::Sb01TrainingFile.find_all_by_parent_id(_kari_id)
      attached_files.each do | af |
        af.move_parent_path(@item.id)
        af.update_attribute(:parent_id, @item.id)
        @dest_folder_name = af.parent_folder_name if @dest_folder_name == ""
      end

      #書き換えた親フォルダ名で本文を修正
      _body = @item.body.gsub(/\/#{_kari_id}\//, '/'+@dest_folder_name.to_s+'/')
      @item.update_attribute(:body, _body)

      location = "#{@public_uri}/#{@item.id}"
      redirect_to location
    else
      @item.id = get_kari_id()
      render :action=>:new
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
    new_item = Gwsub::Sb01Training.set_f(params[:item])
    @item.attributes = new_item
    @fyed_id = params[:item]['fyear_id']
    location = "#{@public_uri}/#{@item.id}"
    options = {
      :success_redirect_uri=>location,
      :after_process=>Proc.new{
      update_schedule_title
      update_members_shcedule_title
    }}
    _update(@item,options)
  end

  def update_schedule_title
    t_skd = Gwsub::Sb01TrainingSchedule.find(:all, :conditions => "training_id = #{@item.id}")
    unless t_skd.blank?
      t_skd.each do |t|
        skd = Gw::Schedule.find_by_id(t.schedule_id)
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
    skd_m = Gwsub::Sb01TrainingScheduleMember.find(:all, :conditions => "training_id = #{@item.id}")
    unless skd_m.blank?
      skd_m.each do |m|
        skd = Gw::Schedule.find_by_id(m.schedule_id)
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
        destroy_schedule
        destroy_members_shcedule
        Gwsub::Sb01TrainingScheduleCondition.destroy_all("training_id = #{@item.id}")
        destroy_attaches(params[:id])
      }
    options = {
      :success_redirect_uri=>location,
      :after_process       =>after_process
    }
    _destroy(@item,options)
  end
  
  #研修を削除したときにその研修に日もづいているUploadファイルも削除する
  def destroy_attaches(id)
    attached_files = Gwsub::Sb01TrainingFile.find_all_by_parent_id(id)
    attached_files.each do | af |
      af.delete_attached_folder
      af.destroy
    end
  end

  def destroy_schedule
    t_skd = Gwsub::Sb01TrainingSchedule.find(:all, :conditions => "training_id = #{@item.id}")
    unless t_skd.blank?
      t_skd.each do |t|
        skd = Gw::Schedule.find_by_id(t.schedule_id)
        skd.destroy unless skd.blank?
        t.destroy
      end
    end
  end

  def destroy_members_shcedule
    skd_m = Gwsub::Sb01TrainingScheduleMember.find(:all, :conditions => "training_id = #{@item.id}")
    unless skd_m.blank?
      skd_m.each do |m|
        skd = Gw::Schedule.find_by_id(m.schedule_id)
        skd.destroy unless skd.blank?
        m.destroy
      end
    end
  end

  def site_url
    @site_url = url_for(:action => 'index' )
    @site_url.sub!(url_for(:action => 'index', :only_path => true).split(/\//).pop, '')
    @site_url.chop! if @site_url[-1, 1] == '/'
  end
  
  def init_params
   
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb01Training.is_dev?(Site.user.id)
    @role_admin      = Gwsub::Sb01Training.is_admin?(Site.user.id)
    @u_role = @role_developer || @role_admin

    # 管理者以外は自所属のみ表示
    if @u_role==true
      @g_id = 0
    else
      @g_id = Site.user_group.id
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
    html_select = "<option value=''>[指定なし]</option>"
    users.each do |value , key|
      html_select << "<option value='#{key}'>#{value}</option>"
    end

    respond_to do |format|
      format.csv { render :text => html_select ,:layout=>false ,:locals=>{:f=>@item} }
    end
  end

  def closed
    init_params
    @item = Gwsub::Sb01Training.new.find(params[:id])
    case @item.state
    when '2'
      @item.state = '3'
      Gwsub::Sb01TrainingSchedule.update_all("state='3'" ,"training_id=#{@item.id}")
    when '3'
      @item.state = '2'
      Gwsub::Sb01TrainingSchedule.update_all("state='2'" ,"training_id=#{@item.id}")
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
      Gwsub::Sb01TrainingSchedule.update_all("state='2'" ,"training_id=#{@item.id}")
    when '2'
      @item.state = '1'
      Gwsub::Sb01TrainingSchedule.update_all("state='1'" ,"training_id=#{@item.id}")
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
    Gwsub::Sb01TrainingSchedule.update_all("state='4'" ,"training_id=#{@item.id}")
    location = "#{@public_uri}/#{@item.id}"
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end
end
