class Gwsub::Admin::Sb05::Sb05MediaTypesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
#    pp ['initialize',params]

    return redirect_to(url_for(action: :index)) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "広報依頼"
  end

  def index
    init_params
    return error_auth unless @u_role==true

#    pp params
#    item = Gwsub::Sb05MediaType.new
#    unless @role_developer==true
#      item.and 'sql','state = 1'
#    end
#    item.search params
#    item.page   params[:page], params[:limit]
#    item.order @sort_keys, 'id ASC'
    order = @sort_keys
    if @role_developer==true
      @items = Gwsub::Sb05MediaType.order(order)
    else
      cond = "(state = 1 or state = 2)"
      @items = Gwsub::Sb05MediaType.where(cond).order(order)
    end
    _index @items
  end
  def show
    init_params
    return error_auth unless @u_role==true

    @item = Gwsub::Sb05MediaType.find(params[:id])
  end

  def new
    init_params
    return error_auth unless @u_role==true

    @l2_current='01'
#    pp ['new',params]
    @item = Gwsub::Sb05MediaType.new({
        :state => 1,
        :max_size=>0
      })
  end
  def create
    init_params
    return error_auth unless @u_role==true

    Gwsub::Sb05MediaType.before_validates_setting(params)
    @item = Gwsub::Sb05MediaType.new(params[:item])
    location = @index_uri
    _create(@item,:success_redirect_uri=>location)
  end

  def edit
    init_params
    return error_auth unless @u_role==true

#    pp ['edit',params]
    @item = Gwsub::Sb05MediaType.find(params[:id])
  end
  def update
    init_params
    return error_auth unless @u_role==true

    Gwsub::Sb05MediaType.before_validates_setting(params)
    @item = Gwsub::Sb05MediaType.new.find(params[:id])
    @item.attributes = params[:item]
    location = @index_uri
    _update(@item,:success_redirect_uri=>location)
  end

  def destroy
    init_params
    return error_auth unless @u_role==true

    item = Gwsub::Sb05MediaType.new.find(params[:id])
    item.state = 3
    item.save(:validate => false)
    location = @index_uri
    redirect_to location
    return
#    _destroy(@item,:success_redirect_uri=>location)
  end

  def csvput
    init_params
    return error_auth unless @u_role==true

    @l2_current='03'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = Gwsub::Sb05MediaType.all.to_csv
    send_data @item.encode(csv), filename: "sb05_media_types_#{@item.encoding}.csv"
  end

  def csvup
    init_params
    return error_auth unless @u_role==true

    @l2_current='04'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    Gwsub::Sb05MediaType.transaction do
      Gwsub::Sb05MediaType.truncate_table
      items = Gwsub::Sb05MediaType.from_csv(@item.file_data)
      items.each(&:save)
    end
    flash[:notice] = '登録処理が完了しました。'
    redirect_to @index_uri
  end

  def init_params
    flash[:notice]=''
    @s_ctl = 'm'
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb05Request.is_dev?
    @role_admin      = Gwsub::Sb05Request.is_admin?
    @u_role = @role_developer || @role_admin
    @role_editor     = Core.user_group.code

    if params[:org_id]=='0'
      @org_id   = 0
      @org_code = 0
      @u_id     = 0
    else
      if params[:org_id]
        @org_id   = params[:org_id]
        @org = System::GroupHistory.find(params[:org_id])
        @org.blank? ? @org_code = 0 : @org_code = @org.code
        @u_id     = 0
      else
        if @u_role == true
          @org_id   = 0
          @org_code = 0
          @u_id     = 0
        else
          @org_id   = Core.user_group.id
          @org_code = Core.user_group.code
          @u_id     = Core.user.id
        end
      end
    end

    # 表示条件設定
    @media_id     = nz(params[:media_id],0)
    @media_code   = nz(params[:media_code],0)
    @r_status     = nz(params[:r_status],3)
    @m_status     = nz(params[:m_status],0)
    params[:org_id]     = nz(params[:org_id],@org_id)
    params[:org_code]   = nz(params[:org_code],@org_code)
    params[:media_id]   = nz(params[:media_id],@media_id)
    params[:media_code] = nz(params[:media_code],@media_code)
    params[:r_status]   = nz(params[:r_status],@r_status)
    params[:m_status]   = nz(params[:m_status],@m_status)
    @view           = nz(params[:view],'n')
    params[:view]  = nz(params[:view],@view)
    # 表示行数　設定
    @limit = nz(params[:limit],30)
    params[:limit]      = nz(params[:limit], @limit)

    search_condition
    setting_sortkeys
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current='04'
    @l2_current='02'

    return
  end
  def search_condition
    qsa = ['limit', 's_keyword' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sortkeys
    @sort_keys = nz(params[:sort_keys], 'media_code ASC , categories_code ASC ,state ASC')
  end

end
