class Gw::Admin::PropExtraPmRemarksController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @is_gw_admin = Gw.is_admin_admin? # GW全体の管理者
    @is_pm_admin = @is_gw_admin || Gw::ScheduleProp.is_pm_admin? # 管財管理者
    return error_auth unless @is_pm_admin

    Page.title = "管財ヘルプリンク"
  end

  def url_options
    super.merge(params.slice(:s_prop_class_id).symbolize_keys) 
  end

  def index
    items = Gw::PropExtraPmRemark.order(:prop_class_id, :sort_no)
    items = items.where(prop_class_id: params[:s_prop_class_id]) if params[:s_prop_class_id].present?
    @items = items.paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = Gw::PropExtraPmRemark.find(params[:id])
  end

  def new
    @item = Gw::PropExtraPmRemark.new(state: 'enabled', prop_class_id: params[:s_prop_class_id])
  end

  def create
    @item = Gw::PropExtraPmRemark.new(params[:item])
    _create @item
  end

  def edit
    @item = Gw::PropExtraPmRemark.find(params[:id])
  end

  def update
    @item = Gw::PropExtraPmRemark.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = Gw::PropExtraPmRemark.find(params[:id])
    _destroy @item
  end
end
