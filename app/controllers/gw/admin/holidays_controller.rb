class Gw::Admin::HolidaysController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  def pre_dispatch
    return error_auth unless Gw.is_admin_admin?
    @css = %w(/_common/themes/gw/css/schedule.css)
    Page.title = "休日管理"
  end

  def index
    @items = Gw::Holiday.order(st_at: :desc).paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = Gw::Holiday.find(params[:id])
  end

  def new
    @item = Gw::Holiday.new
  end

  def create
    @item = Gw::Holiday.new(holiday_params)
    _create @item, notice: '休日の登録に成功しました'
  end

  def edit
    @item = Gw::Holiday.find(params[:id])
  end

  def update
    @item = Gw::Holiday.find(params[:id])
    @item.attributes = holiday_params
    _update @item, notice: "休日の更新に成功しました"
  end

  def destroy
    @item = Gw::Holiday.find(params[:id])
    _destroy @item
  end

private
  def holiday_params
    params.require(:item).permit(:st_at, :title)
  end

end
