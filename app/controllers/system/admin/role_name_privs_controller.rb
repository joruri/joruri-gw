class System::Admin::RoleNamePrivsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    return redirect_to system_role_name_privs_path if params[:reset]

    @is_dev = System::Role.is_dev?
    @is_admin = System::Role.is_admin? || @is_dev
    return error_auth unless @is_admin

    @role_id = nz(params[:role_id], '0')
    @priv_id = nz(params[:priv_id], '0')
    @params_set = System::RoleNamePriv.params_set(params)

    Page.title = "機能権限設定"
  end

  def index
    item = System::RoleNamePriv.new
    item.page  params[:page], params[:limit]
    order = "system_role_names.sort_no, system_priv_names.sort_no"

    if @role_id != '0'
      @items = item.find(:all, :conditions=>"role_id = #{@role_id}", :joins=>[:priv, :role], :order => order)
    else
      @items = item.find(:all, :joins=>[:priv, :role], :order => order)
    end
  end

  def show
    @item = System::RoleNamePriv.find(params[:id])
  end

  def new
    @item = System::RoleNamePriv.new
  end

  def create
    @item = System::RoleNamePriv.new(role_name_priv_params)

    _create @item, :success_redirect_uri => "/system/role_name_privs#{@params_set}", :notice => '機能権限設定の登録に成功しました。'
  end

  def edit
    @item = System::RoleNamePriv.where(:id => params[:id]).first
  end

  def update
    @item = System::RoleNamePriv.find(params[:id])
    @item.attributes = role_name_priv_params

    _update @item, :success_redirect_uri => "/system/role_name_privs/#{@item.id}#{@params_set}",
      :notice => "機能権限設定の更新に成功しました。"
  end

  def destroy
    @item = System::RoleNamePriv.new.find(params[:id])

    _destroy @item, :success_redirect_uri => "/system/role_name_privs#{@params_set}",
      :notice => "機能権限設定の削除に成功しました。"
  end

  def getajax
    role_id = params['role_id']
    @items = Array.new
    if role_id.blank? || role_id == ""
      @items = {:errors=>'空欄です'}
    else
      _items = System::RoleNamePriv.get_priv_items(role_id)

      _items.each_with_index do |_item, i|
        @items << [1, "",  ""] if i == 0
        @items << [1, _item.priv_id,  Gw.trim(_item.priv.display_name)]
      end
    end
    _show @items
  end

private

  def role_name_priv_params
    params.require(:item).permit(:role_id, :priv_id)
  end

end
