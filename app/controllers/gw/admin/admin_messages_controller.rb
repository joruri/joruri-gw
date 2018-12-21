class Gw::Admin::AdminMessagesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @is_admin = Gw::AdminMessage.is_admin?
    return error_auth unless @is_admin

    Page.title = "管理者メッセージ"
  end

  def index
    @items = Gw::AdminMessage.order(state: :asc, sort_no: :asc, updated_at: :desc)
      .paginate(page: params[:page], per_page: 30)
  end

  def show
    @item = Gw::AdminMessage.find(params[:id])
  end

  def new
    @item = Gw::AdminMessage.new
    @item.state = 2
    @item.sort_no = Gw::AdminMessage.maximum(:sort_no).to_i + 10
  end

  def create
    @item = Gw::AdminMessage.new(admin_message_params)
    _create @item
  end

  def edit
    @item = Gw::AdminMessage.find(params[:id])
  end

  def update
    @item = Gw::AdminMessage.find(params[:id])
    @item.attributes = admin_message_params
    _update @item
  end

  def destroy
    @item = Gw::AdminMessage.find(params[:id])
    _destroy @item
  end

private
  def admin_message_params
    params.require(:item).permit(:mode, :state, :sort_no, :body)
  end

end
