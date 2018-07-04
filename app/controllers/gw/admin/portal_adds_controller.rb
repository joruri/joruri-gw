class Gw::Admin::PortalAddsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @u_role = Gw::PortalAdd.is_admin?
    return error_auth unless @u_role

    Page.title = "広告アイコン管理"
  end

  def index
    @items = Gw::PortalAdd.order(sort_no: :asc, publish_start_at: :asc, publish_end_at: :asc)
      .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Gw::PortalAdd.find(params[:id])
  end

  def new
    @item = Gw::PortalAdd.new(
      state: 'enabled',
      published: 'opened',
      is_large: 0,
      sort_no: Gw::PortalAdd.maximum(:sort_no).to_i + 10
    )
  end

  def edit
    @item = Gw::PortalAdd.find(params[:id])
  end

  def create
    @item = Gw::PortalAdd.new(ad_params)
    @item.accept_only_image_file = true
    @item.accept_file_extensions = @item.class::ACCEPT_FILE_EXTENSIONS
    _create @item, notice: '広告画像の登録に成功しました。'
  end

  def update
    @item = Gw::PortalAdd.find(params[:id])
    @item.attributes = ad_params
    @item.accept_only_image_file = true
    @item.accept_file_extensions = @item.class::ACCEPT_FILE_EXTENSIONS
    _update @item, notice: '広告画像の更新に成功しました。'
  end

  def destroy
    @item = Gw::PortalAdd.find(params[:id])
    @item.published      = 'closed'
    @item.state          = 'deleted'
    @item.sort_no        = nil
    @item.deleted_at     = Time.now
    @item.deleted_user   = Core.user.name
    @item.deleted_group  = Core.user_group.name
    @item.save(validate: false)

    redirect_to url_for(action: :index), notice: "指定の広告を削除しました。"
  end

private

  def ad_params
    params.require(:item).permit(:state, :published, :sort_no, :title, :body, :file, :is_large,
      :publish_start_at, :publish_end_at, :class_sso, :url, :field_account, :field_pass)
  end

end
