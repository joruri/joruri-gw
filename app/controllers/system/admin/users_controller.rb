class System::Admin::UsersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    return redirect_to(url_for(action: :index)) if params[:reset]

    @current_no = 1
    @role_developer  = System::User.is_dev?
    @role_admin      = System::User.is_admin?
    @role_editor     = System::User.is_editor?
    @u_role = @role_developer || @role_admin || @role_editor
    return error_auth unless @u_role

    @css = %w(/layout/admin/style.css)
    @limit = nz(params[:limit],30)

    search_condition

    Page.title = "ユーザー・グループ管理"
  end

  def index
    params[:state] = params[:state].presence || 'enabled'

    item = System::User.new
    item.search params
    item.and :ldap, params[:ldap] if params[:ldap] && params[:ldap] != 'all'
    item.and :state, params[:state] if params[:state] && params[:state] != 'all'
    item.page params[:page], nz(params[:limit], 30)
    @items = item.find(:all)

    _index @items
  end

  def show
    @item = System::User.find(params[:id])
  end

  def new
    @top = System::Group.where(:level_no => 1).first
    @group_id = @top.id
    @item = System::User.new({
      :state      =>  'enabled',
      :ldap       =>  '0'
    })
  end

  def create
    @item = System::User.new(params[:item])
    @item.id = params[:item]['id']

    options={
      :location => system_users_path,
      :params=>params
    }
    ret = @item.save_with_rels(options)

    if ret[0]==true
      flash[:notice] = ret[1] || '登録処理が完了しました。'
      status = params[:_created_status] || :created
      options[:location] ||= url_for(:action => :index)
      respond_to do |format|
        format.html { redirect_to options[:location] }
        format.xml  { render :xml => @item.to_xml(:dasherize => false), :status => status, :location => url_for(:action => :index) }
      end
    else
      flash.now[:notice] = '登録処理に失敗しました。' + ' ' + ret[1]
      respond_to do |format|
        format.html { render :action => :new }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @item = System::User.find(params[:id])
  end

  def update
    @item = System::User.find(params[:id])
    @item.attributes = params[:item]

    _update @item, :success_redirect_uri => system_user_path(@item.id)
  end

  def destroy
    @item = System::User.where(:id => params[:id]).first
    @item.state = 'disabled'

    _update @item, {:notice => 'ユーザーを無効状態に更新しました。'}
  end

  def list
    Page.title = "ユーザー・グループ 全一覧画面"

    @groups = System::Group.get_level2_groups
  end

private

  def search_condition
    params[:limit] = nz(params[:limit], @limit)

    qsa = ['limit', 's_keyword']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
end
