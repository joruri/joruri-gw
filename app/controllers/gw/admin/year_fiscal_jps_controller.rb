# encoding: utf-8
class Gw::Admin::YearFiscalJpsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def initialize_scaffold
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    init_params
    return authentication_error(403) unless @is_admin==true

    item = Gw::YearFiscalJp.new
    item.search params
    item.page   params[:page], params[:limit]
    item.order "start_at DESC"
    @items = item.find(:all)
  end
  def show
    init_params
    return authentication_error(403) unless @is_admin==true

    @item = Gw::YearFiscalJp.find(params[:id])
    return http_error(404) if @item.blank?
  end

  def new
    init_params
    return authentication_error(403) unless @is_admin==true

    @item = Gw::YearFiscalJp.new
  end
  def create
    init_params
    return authentication_error(403) unless @is_admin==true

    @item = Gw::YearFiscalJp.new(params[:item])

    location  = "/gw/year_fiscal_jps?#{@qs}"
    options={:success_redirect_uri=>location}
    _create(@item,options)
  end

  def edit
    init_params
    return authentication_error(403) unless @is_admin==true

    @item = Gw::YearFiscalJp.find(params[:id])
    return http_error(404) if @item.blank?
  end
  def update
    init_params
    return authentication_error(403) unless @is_admin==true

    @item = Gw::YearFiscalJp.new.find(params[:id])
    @item.attributes = params[:item]

    location  = "/gw/year_fiscal_jps/#{@item.id}?#{@qs}"
    options={:success_redirect_uri=>location}
    _update(@item,options)
  end

  def destroy
    init_params
    return authentication_error(403) unless @is_admin==true

    @item = Gw::YearFiscalJp.new.find(params[:id])
    return http_error(404) if @item.blank?


    location  = "/gw/year_fiscal_jps?#{@qs}"
    options={:success_redirect_uri=>location}
    _destroy(@item,options)
  end

  def init_params
#    @is_admin = Gw::AdminMessage.is_admin?( Site.user.id )
    @role_developer  = Gw::YearMarkJp.is_dev?
    @role_admin      = Gw::YearMarkJp.is_admin?
    @u_role = @role_developer || @role_admin
    @is_admin = @role_developer || @role_admin

    params[:limit] = nz(params[:limit], 10)
    @limit = params[:limit]

    _search_condition

    @css = %w(/layout/admin/style.css)
    Page.title = "年度設定"
  end

  def _search_condition
#    params[:limit]        = nz(params[:limit],@limit)

    qsa = ['limit', 's_keyword']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

end
