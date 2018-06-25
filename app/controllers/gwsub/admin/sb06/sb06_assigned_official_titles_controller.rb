class Gwsub::Admin::Sb06::Sb06AssignedOfficialTitlesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch

    return redirect_to(url_for(action: :index)) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "担当者名等管理　職名管理"
  end

  def index
    init_params
#    pp params
    item = Gwsub::Sb06AssignedOfficialTitle.new
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end
  def show
    init_params
    @item = Gwsub::Sb06AssignedOfficialTitle.find(params[:id])
  end

  def new
    init_params
    @l3_current='02'
    @item = Gwsub::Sb06AssignedOfficialTitle.new
  end
  def create
    init_params
    @l3_current='02'
    @item = Gwsub::Sb06AssignedOfficialTitle.new(params[:item])
    location = url_for({:action => :index})
    _create(@item,:success_redirect_uri=>location)
  end

  def edit
    init_params
    @item = Gwsub::Sb06AssignedOfficialTitle.find(params[:id])
  end
  def update
    init_params
    @item = Gwsub::Sb06AssignedOfficialTitle.new.find(params[:id])
    @item.attributes = params[:item]
    location = url_for({:action => :index})
    _update(@item,:success_redirect_uri=>location)
  end

  def destroy
    @item = Gwsub::Sb06AssignedOfficialTitle.new.find(params[:id])
    location = url_for({:action => :index})
    _destroy(@item,:success_redirect_uri=>location)
  end

  def csvput
    init_params
    @l3_current='03'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = Gwsub::Sb06AssignedOfficialTitle.all.to_csv(i18n_key: :default)
    send_data @item.encode(csv), filename: "sb06_assigned_official_titles_#{@item.encoding}.csv"
  end

  def csvup
    init_params
    @l3_current='04'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    Gwsub::Sb06AssignedOfficialTitle.transaction do
      Gwsub::Sb06AssignedOfficialTitle.truncate_table
      items = Gwsub::Sb06AssignedOfficialTitle.from_csv(@item.file_data, i18n_key: :default)
      items.each(&:save)
    end

    flash[:notice] = '登録処理が完了しました。'
    redirect_to action: :index
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb06AssignedConference.is_dev?
    @role_admin      = Gwsub::Sb06AssignedConference.is_admin?
    @u_role = @role_developer || @role_admin
    @role_editor     = Core.user_group.code

    @menu_header3 = 'sb0606menu'
    @menu_title3  = 'コード管理'
    @menu_header4 = 'sb06_assigned_official_titles'
    @menu_title4  = '職名'
    # 表示行数　設定
    @limit = nz(params[:limit],30)
    params[:limit]      = nz(params[:limit], @limit)

    search_condition
    setting_sortkeys
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current='04'
    @l2_current='01'
    @l3_current='01'

    return
  end
  def search_condition
    qsa = ['limit', 's_keyword' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sortkeys
    @sort_keys = nz(params[:sort_keys], 'official_title_code ASC')
  end

end
