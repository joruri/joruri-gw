class Gw::Admin::PropTypesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  def pre_dispatch
    @css = %w(/_common/themes/gw/css/prop_extra/schedule.css)
    Page.title = "施設種別マスタ"
    @sp_mode = :prop
    @is_gw_admin = Gw.is_admin_admin?
    return error_auth unless @is_gw_admin
  end

  def index
    @items = Gw::PropType.where(state: "public").order(:sort_no)
      .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Gw::PropType.find(params[:id])
    return http_error(404) if @item.state == "delete"
    _show @item
  end

  def new
    @item = Gw::PropType.new
    @item.restricted = 0
  end

  def create
    @item = Gw::PropType.new(params[:item])
    @item.state = "public"
    _create @item
  end

  def edit
    @item = Gw::PropType.find(params[:id])
    return http_error(404) if @item.state == "delete"
  end

  def update
    @item = Gw::PropType.find(params[:id])
    return http_error(404) if @item.state == "delete"
    @item.attributes = params[:item]

    _update @item
  end

  def destroy
    @item = Gw::PropType.find(params[:id])
    return http_error(404) if @item.state == "delete"

    @item.state = "delete"
    @item.deleted_at = Time.now

    _update @item, :notice => "削除処理は完了しました。"
  end

private

  def type_params
    params.require(:item).permit(:name, :sort_no, :restricted, :user_str)
  end

end
