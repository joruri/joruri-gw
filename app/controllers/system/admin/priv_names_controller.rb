class System::Admin::PrivNamesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @is_dev = System::Role.is_dev?
    @is_admin = System::Role.is_admin?
    return error_auth unless @is_dev

    Page.title = "対象権限設定"
  end

  def index
    @items = System::PrivName.order(:sort_no).paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = System::PrivName.find(params[:id])
  end

  def new
    @item = System::PrivName.new(state: 'public')
  end

  def create
    @item = System::PrivName.new(params[:item])
    _create @item
  end

  def edit
    @item = System::PrivName.find(params[:id])
  end

  def update
    @item = System::PrivName.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = System::PrivName.find(params[:id])
    _destroy @item
  end
end
