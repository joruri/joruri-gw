# encoding: utf-8
class Gw::Admin::AdminMessagesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def initialize_scaffold
    Page.title = "管理者メッセージ"
#    @css = %w(/_common/themes/gw/css/admin_settings.css)
  end

  def index
    init_params
    return authentication_error(403) unless @is_admin==true

    item    = Gw::AdminMessage.new
    order   = 'state ASC , sort_no ASC , updated_at DESC'
    @items  = item.find(:all,:order=>order)
  end
  def show
    init_params
    return authentication_error(403) unless @is_admin==true

    @item = Gw::AdminMessage.find(params[:id])
    return http_error(404) if @item.blank?
  end

  def new
    init_params
    return authentication_error(403) unless @is_admin==true

    @item = Gw::AdminMessage.new
    @item.state = 2
    item = Gw::AdminMessage.find(:first,:order=>'sort_no DESC')
    if item.blank?
      init_sort_no = 10
    else
      init_sort_no = item.sort_no
    end
    @item.sort_no = init_sort_no+10
  end
  def create
    init_params
    return authentication_error(403) unless @is_admin==true

    @item = Gw::AdminMessage.new(params[:item])

    options={:success_redirect_uri=>"/gw/admin_messages?#{@qs}"}
    _create(@item,options)
  end

  def edit
    init_params
    return authentication_error(403) unless @is_admin==true

    @item = Gw::AdminMessage.find(params[:id])
    return http_error(404) if @item.blank?
  end
  def update
    init_params
    return authentication_error(403) unless @is_admin==true
    @item = Gw::AdminMessage.new.find(params[:id])
    @item.attributes = params[:item]

    options={:success_redirect_uri=>"/gw/admin_messages/#{@item.id}?#{@qs}"}
    _update(@item,options)
  end

  def destroy
    init_params
    return authentication_error(403) unless @is_admin==true
    @item = Gw::AdminMessage.new.find(params[:id])
    return http_error(404) if @item.blank?

    options={:success_redirect_uri=>"/gw/admin_messages?#{@qs}"}
    _destroy(@item,options)
  end
  def init_params
    @is_admin = Gw::AdminMessage.is_admin?( Site.user.id )

    qsa = ['limit' , 's_keyword']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

end
