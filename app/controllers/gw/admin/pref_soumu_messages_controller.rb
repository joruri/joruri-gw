class Gw::Admin::PrefSoumuMessagesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @role_admin  = Gw::PrefSoumuMessage.is_admin?
    @role_dev    = Gw::PrefSoumuMessage.is_dev?
    @role_editor = Gw::PrefSoumuMessage.is_editor?
    @u_role = @role_admin || @role_dev ||@role_editor
    return error_auth unless @u_role

    Page.title = 'タブメッセージ'
  end

  def index
    @items = Gw::PrefSoumuMessage.order(state: :asc, sort_no: :asc, updated_at: :desc)
      .paginate(page: params[:page], per_page: 30)
  end

  def show
    @item = Gw::PrefSoumuMessage.find(params[:id])
  end

  def new
    @item = Gw::PrefSoumuMessage.new(
      state: 2,
      sort_no: Gw::PrefSoumuMessage.maximum(:sort_no).to_i + 10,
      tab_keys: Joruri.config.application['gw.pref_soumu_message_tab_key'].presence
    )
  end

  def create
    @item = Gw::PrefSoumuMessage.new(soumu_message_params)
    _create @item
  end

  def edit
    @item = Gw::PrefSoumuMessage.find(params[:id])
  end

  def update
    @item = Gw::PrefSoumuMessage.find(params[:id])
    @item.attributes = soumu_message_params
    _update @item
  end

  def destroy
    @item = Gw::PrefSoumuMessage.find(params[:id])
    _destroy @item
  end

private
  def soumu_message_params
    params.require(:item).permit(:state, :tab_keys, :sort_no, :body)
  end

end
