# encoding: utf-8
class Gw::Admin::PropTypesController < Gw::Admin::PropGenreCommonController
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  def initialize_scaffold
    @css = %w(/_common/themes/gw/css/prop_extra/schedule.css)
    Page.title = "施設種別マスタ"
    @sp_mode = :prop
    @is_gw_admin = Gw.is_admin_admin?
    return authentication_error(403) unless @is_gw_admin
  end

  def index
    item = Gw::PropType.new
    item.page params[:page], params[:limit]
    @items = item.find(:all, :conditions => ["state = ?", "public"], :order => "sort_no")
    
    _index @items
  end

  def show
    @item = Gw::PropType.find_by_id(params[:id])
    return http_error(404) if @item.blank? || @item.state == "delete"
    _show @item
  end

  def new
    @item = Gw::PropType.new
  end

  def create
    @item = Gw::PropType.new(params[:item])
    @item.state = "public"
    _create @item
  end

  def edit
    @item = Gw::PropType.find_by_id(params[:id])
    return http_error(404) if @item.blank? || @item.state == "delete"
  end

  def update
    @item = Gw::PropType.find_by_id(params[:id])
    return http_error(404) if @item.blank? || @item.state == "delete"
    @item.attributes = params[:item]

    _update @item
  end

  def destroy
    @item = Gw::PropType.find_by_id(params[:id])
    return http_error(404) if @item.blank? || @item.state == "delete"
    @item.state = "delete"
    @item.deleted_at  = Time.now
    _update @item, :notice => "削除処理は完了しました。"
  end
end
