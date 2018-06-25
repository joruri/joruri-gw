class Gwsub::Admin::Sb01::Sb01TrainingBoardsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  layout "admin/template/sb01_training"

  def pre_dispatch
    Page.title = "研修申込・受付"
    @public_uri = "/gwsub/sb01/sb01_training_schedule_props"

    # ユーザー権限設定
    @role_developer  = Gwsub::Sb01Training.is_dev?
    @role_admin      = Gwsub::Sb01Training.is_admin?
    @u_role = @role_developer || @role_admin

    return error_auth unless @u_role

    @css = %w(/_common/themes/gw/css/gwsub.css)
    @bbs_items = Gwbbs::Control.where(:state => 'public').order(:sort_no) if params[:action].in?(%w(new create edit update))
  end

  def index
    init_params
    @items = Gwsub::Property::TrainingBoard.paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    init_params
    @item = Gwsub::Property::TrainingBoard.first
    return http_error(404) if @item.blank?
    @bbs_item = Gwbbs::Control.where(:id => @item.options, :state => 'public').first
  end

  def new
    init_params
    @item = Gwsub::Property::TrainingBoard.first_or_new
  end

  def create
    init_params
    @item = Gwsub::Property::TrainingBoard.first_or_new
    @item.attributes = params[:item]
    _create(@item)
  end

  def edit
    init_params
    @item = Gwsub::Property::TrainingBoard.first
    return http_error(404) if @item.blank?
  end

  def update
    init_params
    @item = Gwsub::Property::TrainingBoard.first
    return http_error(404) if @item.blank?
    @item.attributes = params[:item]
    _update(@item)
  end

  def destroy
    init_params
    @item = Gwsub::Property::TrainingBoard.first
    return http_error(404) if @item.blank?
    @item.destroy
    redirect_to url_for({:action => :index})
  end

  def init_params

    # 表示行数　設定
    @limits = nz(params[:limit],30)
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
    @l1_current = '03'
#    @l2_current=nz(params[:l2_c],'01')
    @l2_current='03'
    @l3_current= case params[:action]
    when 'index'
      '01'
    when 'new'
      '02'
    when 'create'
      '02'
    when 'edit'
      '02'
    when 'update'
      '02'
    else
      '01'
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
    @sort_keys = nz(params[:sort_keys], 'updated_at' )
#    @sort_keys = nz(params[:sort_keys], 'fyear_markjp DESC , categories ASC , bbs_url ASC' )
  end

end
