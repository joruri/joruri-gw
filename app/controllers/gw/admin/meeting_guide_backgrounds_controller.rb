class Gw::Admin::MeetingGuideBackgroundsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    Page.title = "会議室案内表示　背景画像管理"

    @is_admin = true # 管理者権限は後に設定する。
    @is_gw_admin = Gw.is_admin_admin? # GW全体の管理者
    @meetings_guide_admin = @is_gw_admin ? true : Gw::Model::Schedule.meetings_guide_admin? # 会議開催案内 管理者
    @u_role = @is_gw_admin || @meetings_guide_admin
    return error_auth unless @u_role
  end

  def index
    @items = Gw::MeetingGuideBackground.order(sort_no: :asc).paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = Gw::MeetingGuideBackground.find(params[:id])
  end

  def new
    @item = Gw::MeetingGuideBackground.new(
      state: 'enabled',
      published: 'opened',
      sort_no: Gw::MeetingGuideBackground.maximum(:sort_no).to_i + 10
    )
  end

  def create
    @item = Gw::MeetingGuideBackground.new(params[:item])
    @item.accept_only_image_file = true
    @item.accept_file_extensions = @item.class::ACCEPT_FILE_EXTENSIONS
    _create @item, notice: '背景画像の登録に成功しました。'
  end

  def edit
    @item = Gw::MeetingGuideBackground.find(params[:id])
  end

  def update
    @item = Gw::MeetingGuideBackground.find(params[:id])
    @item.attributes = params[:item]
    @item.accept_only_image_file = true
    @item.accept_file_extensions = @item.class::ACCEPT_FILE_EXTENSIONS
    _update @item, notice: '背景画像の更新に成功しました。'
  end

  def destroy
    @item = Gw::MeetingGuideBackground.find(params[:id])
    @item.published   = 'closed'
    @item.state       = 'deleted'
    @item.sort_no     = nil
    @item.deleted_at  = Time.now
    @item.deleted_uid = Core.user.id
    @item.deleted_gid = Core.user_group.id
    @item.save(validate: false)

    redirect_to url_for(action: :index), notice: "この背景画像は削除しました。"
  end

  def updown
    item = Gw::MeetingGuideBackground.find(params[:id])

    item_rep = 
      case params[:order]
      when 'up'
        Gw::MeetingGuideBackground.where("sort_no < #{item.sort_no}").order(sort_no: :desc).first!
      when 'down'
        Gw::MeetingGuideBackground.where("sort_no > #{item.sort_no}").order(sort_no: :asc).first!
      end

    item.sort_no, item_rep.sort_no = item_rep.sort_no, item.sort_no
    item.save(validate: false)
    item_rep.save(validate: false)

    redirect_to url_for(action: :index), notice: "並び順の変更に成功しました。"
  end
end
