class Gw::Admin::PropOthersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  before_action :check_auth, only: [:new, :create, :edit, :update, :destroy, :upload, :image_create, :image_destroy]

  def pre_dispatch
    @genre = 'other'
    @model = Gw::PropOther

    @prop_types = Gw::PropType.where(state: "public").select(:id, :name).order(:sort_no, :id)

    # 各種権限取得
    @is_gw_admin = Gw.is_admin_admin? # GW全体の管理者
    @is_pm_admin = @is_gw_admin ? true : Gw::ScheduleProp.is_pm_admin? # 管財管理者
    @is_admin = @is_gw_admin || (params[:id].blank? || Gw::PropOtherRole.is_admin?(params[:id])) # 一般施設の管理権限

    @css = %w(/_common/themes/gw/css/prop_extra/schedule.css)
    Page.title = "一般施設マスタ"
  end

  def url_options
    super.merge(params.slice(:cls).symbolize_keys)
  end

  def index
    item = @model.distinct.where(delete_state: 0)
    item = item.with_user_auth(Core.user, 'admin') unless @is_gw_admin

    if params[:s_type_id].present?
      item = item.where(type_id: params[:s_type_id])
    end
    if params[:s_admin_gid].present?
      if g = System::Group.find_by(id: params[:s_admin_gid])
        gids = [g.id] + g.children.map(&:id)
        item = item.merge(Gw::PropOtherRole.with_auth_and_gids('admin', gids))
      end
    end

    props = Gw::PropOther.arel_table
    types = Gw::PropType.arel_table
    roles = Gw::PropOtherRole.arel_table
    groups = System::Group.arel_table

    @items = item.order(props[:reserved_state].desc, types[:sort_no].asc, groups[:sort_no].asc, props[:sort_no].asc)
      .joins(:prop_type, :prop_other_roles => :group)
      .paginate(page: params[:page], per_page: params[:limit])
      .preload(:prop_type, :prop_other_roles => [:group, :group_history])
  end

  def show
    @item = @model.find(params[:id])
    return http_error(404) if @item.deleted?
  end

  def new
    @item = @model.new

    @admin_json = [["", Core.user_group.id, Core.user_group.name]].to_json
    @editors_json = [["", Core.user_group.id, Core.user_group.name]].to_json
    @readers_json = []
  end

  def create
    @item = @model.new()

    if @item.save_with_rels prop_params, :create
      flash_notice '一般設備の登録', true
      redirect_to url_for(action: :index)
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @item = @model.find(params[:id])

    @admin_json = @item.admin_role_corrected_group_options.to_json
    @editors_json = @item.edit_role_corrected_group_options.to_json
    @readers_json = @item.read_role_corrected_group_options.to_json
  end

  def update
    @item = @model.find(params[:id])
    if @item.save_with_rels prop_params, :update
      flash_notice '一般設備の編集', true
      redirect_to url_for(action: :index)
    else
      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @item = @model.find(params[:id])
    @is_other_admin = Gw::PropOtherRole.is_admin?(params[:id])
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
    params.require(:item).permit(:reserved_state, :sort_no, :name,
      :type_id, :comment, :admin_json, :editors_json, :readers_json,
      :sub => [:extra_flag, :gid, :uid])
  end

  def image_params
    params.require(:item).permit(:file, :note)
  end
end
