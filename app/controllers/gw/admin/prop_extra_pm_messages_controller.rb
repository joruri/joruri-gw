class Gw::Admin::PropExtraPmMessagesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @is_gw_admin = Gw.is_admin_admin? # GW全体の管理者
    @is_pm_admin = @is_gw_admin || Gw::ScheduleProp.is_pm_admin? # 管財管理者
    return error_auth unless @is_pm_admin

    Page.title = "管財管理者メッセージ"
  end

  def url_options
    super.merge(params.slice(:s_prop_class_id).symbolize_keys) 
  end

  def index
    item = Gw::PropExtraPmMessage.order(prop_class_id: :asc, state: :asc, sort_no: :asc, updated_at: :desc)
    item = item.where(prop_class_id: params[:s_prop_class_id]) if params[:s_prop_class_id].present?
    @items = item.paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = Gw::PropExtraPmMessage.find(params[:id])
  end

  def new
    @item = Gw::PropExtraPmMessage.new(state: 2, prop_class_id: params[:s_prop_class_id])
    @item.sort_no = if item = Gw::PropExtraPmMessage.order(sort_no: :desc).first
        item.sort_no + 10
      else
        0
      end
  end

  def create
    @item = Gw::PropExtraPmMessage.new(params[:item])
    _create @item, notice: "メッセージの作成に成功しました。"
  end

  def edit
    @item = Gw::PropExtraPmMessage.find(params[:id])
  end

  def update
    @item = Gw::PropExtraPmMessage.find(params[:id])
    @item.attributes = params[:item]
    _update @item, notice: "メッセージの更新に成功しました。"
  end

  def destroy
    @item = Gw::PropExtraPmMessage.find(params[:id])
    _destroy @item
  end
end
