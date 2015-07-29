# encoding: utf-8
class Gw::Admin::YearMarkJpsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def initialize_scaffold
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    init_params
    return authentication_error(403) unless @u_role

    @sort_keys = nz(params[:sort_keys], 'start_at DESC')
    item = Gw::YearMarkJp.new #.readable
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end

  def show
    init_params
    return authentication_error(403) unless @u_role
    @item = Gw::YearMarkJp.find(params[:id])
    return http_error(404) if @item.blank?
  end

  def new
    init_params
    return authentication_error(403) unless @u_role
    @item = Gw::YearMarkJp.new
  end

  def create
    init_params
    return authentication_error(403) unless @u_role
    @item = Gw::YearMarkJp.new(params[:item])

    location  = "/gw/year_mark_jps?#{@qs}"
    options={:success_redirect_uri=>location}
    _create(@item,options)
  end

  def edit
    init_params
    return authentication_error(403) unless @u_role
    @item = Gw::YearMarkJp.find(params[:id])
    return http_error(404) if @item.blank?

    # 過去年号は編集不可
    cnt =  Gw::YearMarkJp.count(:all , :order=>"start_at DESC" , :conditions=>"start_at > '#{@item.start_at.strftime("%Y-%m-%d 00:00:00")}'")
#    return redirect_to("#{Site.current_node.public_uri}#{@item.id}") if cnt != 0
    return redirect_to("/gw/year_mark_jps/#{@item.id}?#{@qs}") if cnt != 0
  end

  def update
    init_params
    return authentication_error(403) unless @u_role
    @item = Gw::YearMarkJp.new.find(params[:id])
    return http_error(404) if @item.blank?

    # 過去年号は編集不可
    cnt =  Gw::YearMarkJp.count(:all , :order=>"start_at DESC" , :conditions=>"start_at > '#{@item.start_at.strftime("%Y-%m-%d 00:00:00")}'")
#    return redirect_to("#{Site.current_node.public_uri}#{@item.id}") if cnt != 0
    return redirect_to("/gw/year_mark_jps/#{@item.id}?#{@qs}") if cnt != 0

    @item.attributes = params[:item]

    location  = "/gw/year_mark_jps/#{@item.id}?#{@qs}"
    options={:success_redirect_uri=>location}
    _update(@item,options)
  end

  def destroy
    init_params
    return authentication_error(403) unless @u_role
    @item = Gw::YearMarkJp.new.find(params[:id])
    return http_error(404) if @item.blank?

    # 過去年号は削除不可
    cnt =  Gw::YearMarkJp.count(:all , :order=>"start_at DESC" , :conditions=>"start_at > '#{@item.start_at.strftime("%Y-%m-%d 00:00:00")}'")
#    return redirect_to("#{Site.current_node.public_uri}#{@item.id}") if cnt != 0
    return redirect_to("/gw/year_mark_jps/#{@item.id}?#{@qs}") if cnt != 0

    location  = "/gw/year_mark_jps?#{@qs}"
    options={:success_redirect_uri=>location}
    _destroy(@item,options)
  end

  def init_params
    @role_developer  = Gw::YearMarkJp.is_dev?
    @role_admin      = Gw::YearMarkJp.is_admin?
    @u_role = @role_developer || @role_admin

    @limit = nz(params[:limit],10)

    search_condition
    sortkeys_setting

    @css = %w(/layout/admin/style.css)
    Page.title = "年号設定"
  end

  def search_condition
    params[:limit]        = nz(params[:limit],@limit)

    qsa = ['limit', 's_keyword']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

  def sortkeys_setting
     @sort_keys = nz(params[:sort_keys], 'start_at DESC')
  end

end
