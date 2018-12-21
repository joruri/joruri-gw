class Gw::Admin::PropGenreCommonController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  before_action :check_auth, only: [:new, :create, :edit, :update, :destroy, :upload, :image_create, :image_destroy]

  def pre_dispatch
    @sp_mode = :prop
    return redirect_to(url_for(action: :index)) if params[:reset]
  end

  def init_params
    # 各種権限取得
    @is_gw_admin = Gw.is_admin_admin? # GW全体の管理者
    @is_pm_admin = @is_gw_admin ? true : Gw::ScheduleProp.is_pm_admin? # 管財管理者
    @is_admin = @is_gw_admin || @is_pm_admin

    @css = %w(/_common/themes/gw/css/prop_extra/schedule.css)
    Page.title = "#{@model.model_name.human}マスタ"
  end

  def url_options
    super.merge(params.slice(:cls).symbolize_keys)
  end

  def index
    @items = @model
    @items = @items.where(delete_state: 0) unless @is_admin
    @items = @items.order(delete_state: :asc, reserved_state: :desc, gid: :asc, sort_no: :asc, name: :asc)
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = @model.find(params[:id])
  end

  def new
    @item = @model.new(
      delete_state: 0,
      reserved_state: 1,
      extra_flag: 'pm',
      gid: Joruri.config.application['gw.prop_rentcar_owner_group_id'].presence || Core.user_group.id
    )
  end

  def create
    @item = @model.new(prop_params)
    _create @item, notice: "#{@model.model_name.human}の登録に成功しました"
  end

  def edit
    @item = @model.find(params[:id])
  end

  def update
    @item = @model.find(params[:id])
    @item.attributes = prop_params
    _update @item, notice: "#{@model.model_name.human}の更新に成功しました"
  end

  def destroy
    @item = @model.find(params[:id])
    @item.delete_state = 1
    _update @item, notice: "#{@model.model_name.human}の削除に成功しました"
  end

  def upload
    @item = @model.find(params[:id])
    @image_item = @item.images.build
  end

  def image_create
    @item = @model.find(params[:id])
    @image_item = @item.images.build(image_params)

    if @image_item.save
      redirect_to url_for(action: :upload), notice: "#{@model.model_name.human}画像の追加に成功しました。"
    else
      render :upload
    end
  end

  def image_destroy
    @item = @model.find(params[:id])
    @image_item = @item.images.find(params[:image_id])

    if @image_item.destroy
      redirect_to url_for(action: :upload), notice: "#{@model.model_name.human}画像の削除に成功しました。"
    else
      render :upload
    end
  end

  private

  def check_auth
    return error_auth unless @is_admin
  end

  def prop_params
    params.require(:item).permit(:reserved_state, :sort_no, :car_model,
      :name, :type_id, :position,
      :register_no, :exhaust, :year_type,
      :comment, :delete_state,
      :extra_flag, :gid,
      :max_person, :max_tables, :max_chairs,
      :meter => [:travelled_km])
  end

  def image_params
    params.require(:item).permit(:file, :note)
  end
end
