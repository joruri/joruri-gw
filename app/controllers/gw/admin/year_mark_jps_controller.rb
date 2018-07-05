class Gw::Admin::YearMarkJpsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    return redirect_to(url_for(action: :index)) if params[:reset]

    @role_developer = Gw::YearMarkJp.is_dev?
    @role_admin = Gw::YearMarkJp.is_admin?
    @u_role = @role_developer || @role_admin
    return error_auth unless @u_role

    Page.title = "年号設定"
  end

  def url_options
    super.merge(params.slice(:limit, :s_keyword).symbolize_keys)
  end

  def index
    @items = Gw::YearMarkJp.search_with_text(:name, :mark, params[:s_keyword]).order(id: :desc)
      .paginate(page: params[:page], per_page: params[:limit].presence || 10)

    _index @items
  end

  def show
    @item = Gw::YearMarkJp.find(params[:id])
  end

  def new
    @item = Gw::YearMarkJp.new
  end

  def create
    @item = Gw::YearMarkJp.new(mark_jp_params)
    _create @item
  end

  def edit
    @item = Gw::YearMarkJp.find(params[:id])
  end

  def update
    @item = Gw::YearMarkJp.find(params[:id])
    @item.attributes = mark_jp_params
    _update @item
  end

  def destroy
    @item = Gw::YearMarkJp.find(params[:id])
    _destroy @item
  end

private

  def mark_jp_params
    params.require(:item).permit(:name, :mark, :start_at)
  end
end
