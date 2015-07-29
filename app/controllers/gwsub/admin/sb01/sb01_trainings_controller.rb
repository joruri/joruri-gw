# -*- encoding: utf-8 -*-
class Gwsub::Admin::Sb01::Sb01TrainingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::SortKey
  include Gwbbs::Model::DbnameAlias
  include Gwboard::Controller::Authorize

  # 研修掲示板の管理者向けツール（掲示板一覧リンクの登録・編集・削除）
  layout "admin/template/sb01_training"

  def pre_dispatch
    Page.title = "研修申込・受付"
    @public_uri = "/gwsub/sb01/sb01_trainings"
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    init_params
    item = Gwsub::Sb01Training.new
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end
  
  def index_over
    init_params
    @l3_current=nz(params[:l3_c],'02')
    item = Gwsub::Sb01Training.new
    item.search params
    item.page   params[:page], params[:limit]
    @sort_keys = nz(params[:sort_keys], 'categories ASC , fyear_markjp DESC , gwsub_sb01_training_schedules.from_start ASC' )
    item.order  params[:id], @sort_keys
    joins = 'INNER JOIN gwsub_sb01_training_schedules ON gwsub_sb01_trainings.id = gwsub_sb01_training_scheduls.training_id'
    cond = 'gwsub_sb01_trainings.state = 2'
    @items = item.find(:all,
      :select => 'distinct gwsub_sb01_trainings.*',
      :count    => { :select => "DISTINCT gwsub_sb01_trainings.id"},
      :joins  => joins,
      :conditions=>cond
      )
    _index @items
  end

  def show
    init_params
    @item = Gwsub::Sb01Training.find(params[:id])
  end

  def new
    init_params
    #@l2_current=nz(params[:l2_c],'02')
    @l3_current=nz(params[:l3_c],'02')
    @item = Gwsub::Sb01Training.new
    @item.state = '1'
  end

  def create
    init_params
    new_item = Gwsub::Sb01Training.set_f(params[:item])
    @item = Gwsub::Sb01Training.new(new_item)
    @cat = @item.categories
    @fyed_id = @item.fyear_id
    location = @public_uri
    options = {
      :success_redirect_uri=>location,
    }
    _create(@item,options)
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
    location = "#{@public_uri}/#{@item.id}"
    today = Time.now.strftime("%Y-%m-%d 00:00")
    skd_cond = @item.schedule_conditions(:all, :conditions => ['from_at > ?', today])
    return redirect_to location unless skd_cond.size == 0
    new_item = Gwsub::Sb01Training.set_f(params[:item])
    @item.attributes = new_item
    @fyed_id = params[:item]['fyear_id']
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

  def destroy
    init_params
    @item = Gwsub::Sb01Training.find(params[:id])
    bbs_url = @item.bbs_url
    location = @public_uri
    after_process = Proc.new{
        destroy_schedule
        destroy_members_shcedule
        Gwsub::Sb01TrainingScheduleCondition.destroy_all("training_id = #{@item.id}")
      }
    options = {
      :success_redirect_uri=>location,
      :after_process       =>after_process
    }
    _destroy(@item,options)
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

  def expired
    init_params
    @item = Gwsub::Sb01Training.find(params[:id])
    @item.state = '4'
    Gwsub::Sb01TrainingSchedule.update_all("state='4'" ,"training_id=#{@item.id}")
    location = "#{@public_uri}/#{@item.id}"
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

  def closed
    init_params
    @item = Gwsub::Sb01Training.new.find(params[:id])
    case @item.state
    when '3'
      @item.state = '2'
      Gwsub::Sb01TrainingSchedule.update_all("state='2'" ,"training_id=#{@item.id}")
    else
      @item.state = '3'
      Gwsub::Sb01TrainingSchedule.update_all("state='3'" ,"training_id=#{@item.id}")
    end
    location = "#{@public_uri}/#{@item.id}"
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

  def init_params
    @system ='sb01_training'
    
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb01Training.is_dev?(Site.user.id)
    @role_admin      = Gwsub::Sb01Training.is_admin?(Site.user.id)
    @u_role = @role_developer || @role_admin
    
    # 対象年度　設定
    @fyed_id = nz(params[:fyed_id],0)
    # 表示行数　設定
    @limits = nz(params[:limit],30)
    # 掲示板分類
    # catgories : 掲示板分類（1:研修一覧・2:受講者向け利用方法・3:企画者向け利用方法）
    @cat = nz(params[:cat],'0')
    @menu_title = "管理者"
    @v = nz(params[:v],'1')

    @bbs_link_title  = '別ウィンドウ・別タブで案内記事を開きます'

    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current=nz(params[:l1_c],'03')
    @l2_current=nz(params[:l2_c],'01')
    @l3_current=nz(params[:l3_c],'01')
  end

  def search_condition
    params[:fyed_id]  = nz(params[:fyed_id], @fyed_id)
    params[:cat]      = nz(params[:cat], @cat)
    params[:limit]    = nz(params[:limit], @limits)

    qsa = ['limit' , 's_keyword' , 'cat' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'categories ASC , fyear_markjp DESC , updated_at DESC' )
  end
end