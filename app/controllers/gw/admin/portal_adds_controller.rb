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
    @item = Gw::PortalAdd.new(params[:item])
    @item.accept_only_image_file = true
    @item.accept_file_extensions = @item.class::ACCEPT_FILE_EXTENSIONS
    _create @item, notice: '広告画像の登録に成功しました。'
  end

  def update
    @item = Gw::PortalAdd.find(params[:id])
    @item.attributes = params[:item]
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

  def updown
    item = Gw::PortalAdd.find(params[:id])
    item_rep = case params[:order]
      when 'up'
        Gw::PortalAdd.where("sort_no < #{item.sort_no}").order(sort_no: :desc).first!
      when 'down'
        Gw::PortalAdd.where("sort_no > #{item.sort_no}").order(sort_no: :asc).first!
      end

    item.sort_no, item_rep.sort_no = item_rep.sort_no, item.sort_no
    item.save(validate: false)
    item_rep.save(validate: false)

    redirect_to url_for(action: :index), notice: "並び順の変更に成功しました。"
  end
end
