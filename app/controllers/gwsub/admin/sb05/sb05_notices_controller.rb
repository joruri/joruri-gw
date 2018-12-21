class Gwsub::Admin::Sb05::Sb05NoticesController < Gw::Controller::Admin::Base
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

    item = Gwsub::Sb05Notice.new
    item.search params
    item.and 'sql','gwsub_sb05_media_types.state=1'
    item.page   params[:page], params[:limit]
    item.order  @sort_keys
    joins = "left join gwsub_sb05_media_types on gwsub_sb05_media_types.id = gwsub_sb05_notices.media_id"
    @items = item.find(:all,:joins=>joins)
    _index @items
  end
  def show
    init_params
    return error_auth unless @u_role==true

    @item = Gwsub::Sb05Notice.find(params[:id])
  end

  def new
    init_params
    return error_auth unless @u_role==true

    @l2_current ='01'
    @item = Gwsub::Sb05Notice.new({
    })
  end
  def create
    init_params
    return error_auth unless @u_role==true

    @item = Gwsub::Sb05Notice.new(notice_params)
    location = @index_uri
    options = {
      :success_redirect_uri=>location
    }
    _create(@item,options)
  end

  def edit
    init_params
    return error_auth unless @u_role==true

    @item = Gwsub::Sb05Notice.find(params[:id])
  end
  def update
    init_params
    return error_auth unless @u_role==true

    @item = Gwsub::Sb05Notice.new.find(params[:id])
    @item.attributes = notice_params
    location = @index_uri
    options = {
      :success_redirect_uri=>location,
    }
    _update(@item,options)
  end

  def destroy
    init_params
    return error_auth unless @u_role==true

    @item = Gwsub::Sb05Notice.new.find(params[:id])
    location = @index_uri
    options = {
      :success_redirect_uri=>location,
    }
    _destroy(@item,options)
  end

  def csvput
    init_params
    return error_auth unless @u_role==true

    @l2_current ='03'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = Gwsub::Sb05Notice.all.to_csv
    send_data @item.encode(csv), "sb05_notice_#{@item.encoding}.csv"
  end

  def csvup
    init_params
    return error_auth unless @u_role==true

    @l2_current ='04'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    Gwsub::Sb05Notice.transaction do
      Gwsub::Sb05Notice.truncate_table
      items = Gwsub::Sb05Notice.from_csv(@item.file_data)
      items.each(&:save)
    end

    flash[:notice] = '登録処理が完了しました。'
    redirect_to @index_uri
  end

  def init_params
    flash[:notice]=''
    @s_ctl = 'n'
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb05Request.is_dev?
    @role_admin      = Gwsub::Sb05Request.is_admin?
    @u_role = @role_developer || @role_admin

    # 表示条件設定
    media_ids   = Gwsub::Sb05MediaType.order("id ASC").collect{|x| x.id}
    media_codes = Gwsub::Sb05MediaType.order("id ASC").collect{|x| x.media_code}
    @media_id     = nz(params[:media_id]    ,'0')
    @media_code   = nz(params[:media_code]  ,'0')
    @media_id     = media_ids[0]    if @media_id    != '0' && media_ids.index(@media_id.to_i) == nil
    @media_code   = media_codes[0]  if @media_code  != '0' && media_codes.index(@media_code.to_i) == nil
    # 表示行数　設定
    @limit = nz(params[:limit],10)

    search_condition
    setting_sortkeys
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current ='05'
    @l2_current ='02'
    return
  end
  def search_condition
    params[:limit]      = nz(params[:limit], @limit)
    params[:media_id]   = @media_id     if params[:media_id]
    params[:media_code] = @media_code   if params[:media_code]
    qsa = ['limit' , 's_keyword' , 'media_id' , 'media_code' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sortkeys
    @sort_keys = nz(params[:sort_keys], 'media_code ASC , categories_code ASC')
  end

private

  def notice_params
    params.require(:item).permit(:media_id, :sample, :form_templates, :admin_remarks)
  end

end
