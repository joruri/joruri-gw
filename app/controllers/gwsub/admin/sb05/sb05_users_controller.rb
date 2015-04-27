class Gwsub::Admin::Sb05::Sb05UsersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "広報依頼"
  end

  def index
    init_params
#    pp params
    item = Gwsub::Sb05User.new
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @users = item.find(:all)
    _index @users
  end

  def show
    init_params
    @user = Gwsub::Sb05User.find(params[:id])
  end

  def new
    init_params
    @l2_current = '01'
    @user = Gwsub::Sb05User.new({
      :notes_imported => nil ,
      :user_id => Core.user.id,
      :user_code => Core.user.code,
      :user_name => Core.user.name,
      :org_id => Core.user_group.id,
      :org_code => Core.user_group.code,
      :org_name => Core.user_group.name
    })
  end
  def create
    init_params
#    pp ['create',params]
    @user = Gwsub::Sb05User.new(params[:user])
    case @n_from
    when 'r'
      # 依頼登録からのルートは、依頼登録に戻す
      location = "/gwsub/sb05//sb05_requests/new?"
      options={
        :success_redirect_uri=>location ,
        :notice => '連絡先登録が完了しました'
      }
    else
      # 連絡先登録からのルートは、連絡先一覧に戻す
      location = @index_uri
      options={ :success_redirect_uri=>location }
    end
    _create(@user,options)
  end

  def edit
    init_params
#    pp ['edit',params]
    @user = Gwsub::Sb05User.find(params[:id])
    @user.notes_imported = nil
  end
  def update
    init_params
#    pp ['update',params]
    @user = Gwsub::Sb05User.new.find(params[:id])
    @user.attributes = params[:user]
    location = "#{@index_uri}#{@user.id}"
    # 更新できたら、requestの連絡先情報も更新する。

    options={
      :success_redirect_uri=>location,
      :after_process=>Proc.new{
#        cond="sb05_users_id=#{params[:id]}"
        cond="sb05_users_id=#{params[:id]} and org_code='#{@user.org_code}' and org_name='#{@user.org_name}'"
        requests = Gwsub::Sb05Request.where(cond)
        requests.each do |x|
          x.telephone = params[:user]['telephone']
          x.save
        end
      }
    }
    _update(@user,options)
  end

  def destroy
    init_params
#    pp ['destroy',params]
    @user = Gwsub::Sb05User.find(params[:id])
    r_cond="sb05_users_id='#{@user.id}'"
    request_counts = Gwsub::Sb05Request.count(:all,:conditions=>r_cond)
    if request_counts == 0
#      flash[:notice] = '削除は準備中です'
      location = @index_uri
      options={
        :success_redirect_uri=>location
        }
      _destroy(@user,options)
    else
      flash[:notice] = '依頼を登録済のため、削除できません。'
      location = "#{@index_uri}#{@user.id}"
      redirect_to location
    end
  end

  def csvput
    init_params
    @l2_current = '03'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]

    csv = Gwsub::Sb05User.all.to_csv
    send_data @item.encode(csv), filename: "sb05_users_#{@item.encoding}.csv"
  end

  def csvup
    init_params
    @l2_current = '04'

    @item = System::Model::FileConf.new(encoding: 'sjis')
    return if params[:item].nil?

    @item.attributes = params[:item]
    return unless @item.valid_file?

    Gwsub::Sb05User.transaction do
      Gwsub::Sb05User.truncate_table
      items = Gwsub::Sb05User.from_csv(@item.file_data)
      items.each(&:save)
    end
    flash[:notice] = '登録処理が完了しました。'
    redirect_to @index_uri
  end

  def init_params
#    flash[:notice]=''
    @s_ctl = 'u'
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb05Request.is_dev?
    @role_admin      = Gwsub::Sb05Request.is_admin?
    @u_role = @role_developer || @role_admin
    @role_edit_grp    = Core.user_group.code

    # 所属絞込条件設定
    if @u_role != true
      params[:org_id]   ? @org_id   = params[:org_id]   : @org_id   = Core.user_group.id
      params[:org_code] ? @org_code = params[:org_code] : @org_code = Core.user_group.code
      params[:org_name] ? @org_name = params[:org_name] : @org_name = Core.user_group.name
      @u_id     = Core.user.id
    else
      if params[:org_id]=='0'
        @org_id   = 0
        @org_code = nil
        @org_name = nil
        @u_id     = 0
      else
        if params[:org_id]
          @org_id   = params[:org_id]
          @org = System::GroupHistory.find(params[:org_id])
          @org.blank? ? @org_code = nil : @org_code = @org.code
          @org.blank? ? @org_name = nil : @org_name = @org.name
          @u_id     = 0
        else
          @org_id   = 0
          @org_code = nil
          @org_name = nil
          @u_id     = 0
        end
      end
    end
    # 新規登録ルート
    @n_from = nz(params[:n_from],'u')
    # 表示行数　設定
    @limit = nz(params[:limit],30)
    params[:limit]      = nz(params[:limit], @limit)

    search_condition
    setting_sortkeys
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current = '02'
    if @n_form  ==  'r'
      @l1_current = '01'
    end
    @l2_current = '02'
  end
  def search_condition
#    params[:org_id]     = nz(params[:org_id],@org_id)
    params[:org_id]    = @org_id
    params[:org_code]   = @org_code
    params[:org_name]   = @org_name
    qsa = ['limit' , 's_keyword' , 'org_id' , 'org_code' , 'org_name' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sortkeys
    @sort_keys = nz(params[:sort_keys], 'org_code ASC , org_name ASC , user_name ASC , created_at ASC ')
  end
end
