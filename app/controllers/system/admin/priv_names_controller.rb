class System::Admin::PrivNamesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @is_dev = System::Role.is_dev?
    @is_admin = System::Role.is_admin? || @is_dev
    return error_auth unless @is_admin

    search_condition

    Page.title = "対象権限設定"
  end

  def index
    @items = System::PrivName.order(:sort_no).paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = System::PrivName.find(params[:id])
  end

  def new
    @item = System::PrivName.new(:state => 'public')
  end

  def create
    @item = System::PrivName.new(params[:item])

    _create @item, :success_redirect_uri => "/system/priv_names?#{@qs}"
  end

  def edit
    @item = System::PrivName.where(:id => params[:id]).first
  end

  def update
    @item = System::PrivName.find(params[:id])
    @item.attributes = params[:item]

    _update @item,:success_redirect_uri => "/system/priv_names/#{@item.id}?#{@qs}"
  end

  def destroy
    @item = System::PrivName.find(params[:id])

    _destroy @item, :success_redirect_uri => "/system/priv_names?#{@qs}"
  end

private

  def search_condition
    params[:role_id] = nz(params[:role_id], @role_id)

    qsa = ['role_id' , 'priv_id' , 'role' , 'priv_user']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
end
