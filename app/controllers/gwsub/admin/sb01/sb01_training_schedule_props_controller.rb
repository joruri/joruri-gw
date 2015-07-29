# -*- encoding: utf-8 -*-
class Gwsub::Admin::Sb01::Sb01TrainingSchedulePropsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  layout "admin/template/sb01_training"

  def pre_dispatch
    Page.title = "研修申込・受付"
    @public_uri = "/gwsub/sb01/sb01_training_schedule_props"
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    init_params
    @item1 = Gwsub::Sb01Training.find(@t_id)
    item = Gwsub::Sb01TrainingScheduleProp.new
    item.search params
#    item.creator
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end
  def show
    init_params
    @item1 = Gwsub::Sb01Training.find(@t_id)
    @item = Gwsub::Sb01TrainingScheduleProp.find(params[:id])
    @p_id = @item.id
  end

  def new
    init_params
    @item = Gwsub::Sb01TrainingScheduleProp.new({
        :state => '1'
      })
  end
  def create
    init_params
    new_item = Gwsub::Sb01TrainingScheduleProp.set_f(params[:item])
    @item = Gwsub::Sb01TrainingScheduleProp.new(new_item)
    location = @public_uri
    options = {
      :success_redirect_uri=>location,
    }
    _create(@item,options)
  end

  def edit
    init_params
    @item = Gwsub::Sb01TrainingScheduleProp.find(params[:id])
  end
  def update
    init_params
    @item = Gwsub::Sb01TrainingScheduleProp.find(params[:id])
    @trainig = Gwsub::Sb01Training.find(@item.training_id)
    case @training.state
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
    new_item = Gwsub::Sb01TrainingScheduleProp.set_f(params[:item])
    @item.attributes = new_item
    location = "#{@public_uri}/#{@item.id}"
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

  def destroy
    init_params
    @item = Gwsub::Sb01TrainingScheduleProp.find(params[:id])
    location = @public_uri
    redirect_to location
#    options = {
#      :success_redirect_uri=>location,
#    }
#    _destroy(@item,options)
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb01Training.is_dev?(Site.user.id)
    @role_admin      = Gwsub::Sb01Training.is_admin?(Site.user.id)
    @u_role = @role_developer || @role_admin

    # 表示行数　設定
    @limits = nz(params[:limit],30)
    # 研修id
    @t_id_top = Gwsub::Sb01Training.find(:first,:order=>"fyear_markjp DESC")
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
    when 'entries'
      @l1_current=nz(params[:l1_c],'01')
    else
      @l1_current=nil
    end
#    @l2_current=nz(params[:l2_c],'01')
    case params[:v].to_i
    when 1
      @l2_current='01'
    when 2
      @l2_current='02'
    when 3
      @l2_current='03'
    else
      @l2_current='01'
    end
#pp params
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
#    @sort_keys = nz(params[:sort_keys], 'fyear_markjp DESC , categories ASC , bbs_url ASC' )
  end

  def closed
    init_params
    @item = Gwsub::Sb01TrainingScheduleProp.find(params[:id])
    case @item.state
    when '2'
      @item.state = '3'
    when '3'
      @item.state = '2'
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
    @item = Gwsub::Sb01TrainingScheduleProp.find(params[:id])
    case @item.state
    when '1'
      @item.state = '2'
    when '2'
      @item.state = '1'
    else
    end
    location = "#{@public_uri}/#{@item.id}?t_id=#{@t_id}&t_menu=#{@top_menu}"
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end
end
