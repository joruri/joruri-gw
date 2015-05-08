class Gw::Admin::EditLinkPieceCssesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @is_gw_admin = Gw.is_admin_admin?
    @role_developer = Gw::EditLinkPiece.is_dev?
    @edit_link_piece_admin = Gw::EditLinkPiece.is_admin?
    @edit_link_piece_editor = Gw::EditLinkPiece.is_editor?
    @u_role = @is_gw_admin || @role_developer || @edit_link_piece_admin || @edit_link_piece_editor
    return error_auth unless @u_role

    Page.title = "ポータルリンクピース適用CSS編集"
  end

  def index
    @items = Gw::EditLinkPieceCss.order(css_sort_no: :asc)
      .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Gw::EditLinkPieceCss.find(params[:id])
  end

  def new
    @item = Gw::EditLinkPieceCss.new
    @item.state = 'enabled'
    @item.css_sort_no = Gw::EditLinkPieceCss.maximum(:css_sort_no).to_i + 10
  end

  def create
    @item = Gw::EditLinkPieceCss.new(params[:item])
    _create @item
  end

  def edit
    @item = Gw::EditLinkPieceCss.find(params[:id])
  end

  def update
    @item = Gw::EditLinkPieceCss.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = Gw::EditLinkPieceCss.find(params[:id])
    @item.state          = 'deleted'
    @item.css_sort_no    = nil
    @item.deleted_at     = Time.now
    @item.deleted_user   = Core.user.name
    @item.deleted_group  = Core.user_group.name

    _update @item, notice: "#{@item.css_name}の削除に成功しました"
  end
end
