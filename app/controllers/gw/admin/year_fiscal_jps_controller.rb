class Gw::Admin::YearFiscalJpsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    return redirect_to(url_for(action: :index)) if params[:reset]

    @role_developer = Gw::YearMarkJp.is_dev?
    @role_admin = Gw::YearMarkJp.is_admin?
    @u_role = @role_developer || @role_admin
    @is_admin = @role_developer || @role_admin
    return error_auth unless @is_admin

    Page.title = "年度設定"
  end

  def url_options
    super.merge(params.slice(:limit, :s_keyword).symbolize_keys)
  end

  def index
    @items = Gw::YearFiscalJp.search_with_text(:fyear, :markjp, :namejp, params[:s_keyword]).order(start_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit].presence || 10)
  end

  def show
    @item = Gw::YearFiscalJp.find(params[:id])
  end

  def new
    @item = Gw::YearFiscalJp.new
  end

  def create
    @item = Gw::YearFiscalJp.new(params[:item])
    _create @item
  end

  def edit
    @item = Gw::YearFiscalJp.find(params[:id])
  end

  def update
    @item = Gw::YearFiscalJp.find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = Gw::YearFiscalJp.find(params[:id])
    _destroy @item
  end
end
