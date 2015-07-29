#encoding:utf-8
class Gwmonitor::Admin::BuildersController < Gw::Controller::Admin::Base

  include System::Controller::Scaffold
  include Gwmonitor::Model::Database
  include Gwmonitor::Controller::Systemname

  layout "admin/template/gwmonitor"

  def public_uri
    return "/gwmonitor/builders"
  end

  def pre_dispatch
    Page.title = "照会・回答システム"
    @system_title = disp_system_name
    @css = ["/_common/themes/gw/css/monitor.css"]
    page_limit_default_setting
  end

  def index
    system_admin_flags
    if @is_sysadm
      admin_index
    else
      normal_index
    end
  end

  def admin_index
    item = Gwmonitor::Control.new
    item.and :state, '!=' , 'preparation'
    item.page(params[:page], params[:limit])
    @items = item.find(:all, :order=>'expiry_date DESC, id DESC')
  end

  def normal_index
    sql = Condition.new
    sql.or {|d|
      d.and :state, '!=' , 'preparation'
      d.and :admin_setting , 0
      d.and :creater_id, Site.user.code
    }
    sql.or {|d|
      d.and :state, '!=' , 'preparation'
      d.and :admin_setting , 1
      d.and :section_code, Site.user_group.code
    }
    item = Gwmonitor::Control.new
    item.page(params[:page], params[:limit])
    @items = item.find(:all, :conditions=>sql.where, :order=>'expiry_date DESC, id DESC')
  end

  def is_creator
    system_admin_flags
    ret = false
    ret = true if @is_sysadm
    ret = true if @item.creater_id == Site.user.code  if @item.admin_setting == 0
    ret = true if @item.section_code == Site.user_group.code  if @item.admin_setting == 1
    return ret
  end

  def show
    @item = Gwmonitor::Control.find_by_id(params[:id])
    return http_error(404) unless @item
    return http_error(404) if @item.state == 'preparation'
    return authentication_error(403) unless is_creator
  end

  def edit
    @item = Gwmonitor::Control.find_by_id(params[:id])
    return http_error(404) unless @item
    return authentication_error(403) unless is_creator
  end

  def update
    @item = Gwmonitor::Control.find_by_id(params[:id])
    return http_error(404) unless @item

    @before_state = @item.state

    @item.attributes = params[:item]
    @item.state = params[:item][:state]
    @item.state = 'closed' if @before_state == 'closed'

    @item.form_id = 1
    @item.upload_system = 3 #
    @item.reminder_start_personal = 0
    @item._commission_state = @before_state

    if (@before_state == 'preparation') || (@before_state == 'draft')
      @item.able_date = Time.now
    end

    @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    unless @is_sysadm
      @item.section_code = Site.user_group.code
      @item.creater_id = Site.user.code
      @item.creater = Site.user.name
      @item.createrdivision = Site.user_group.name
      @item.createrdivision_id = Site.user_group.code
    end

    location = public_uri
    _update(@item, :success_redirect_uri=>location)
  end

  def new
    @item = Gwmonitor::Control.create({
      :state => 'preparation',
      :section_code => Site.user_group.code ,
      :send_change => '1',  #配信先は所属
      :spec_config => 3 ,   #他の回答者名を表示する
      :able_date => Time.now.strftime("%Y-%m-%d %H:%M"),
      :expiry_date => 7.days.since.strftime("%Y-%m-%d %H:00"),
      :upload_graphic_file_size_capacity => 100, #初期値900MB
      :upload_graphic_file_size_capacity_unit => 'MB',
      :upload_document_file_size_capacity => 1,  #初期値1G
      :upload_document_file_size_capacity_unit => 'GB',
      :upload_graphic_file_size_max => 50, #初期値5MB
      :upload_document_file_size_max => 500, #初期値300MB
      :upload_graphic_file_size_currently => 0,
      :upload_document_file_size_currently => 0 ,
      :reminder_start_section => 3, #デフォルト3日
      :reminder_start_personal => 0,
      :default_limit => 100 ,
      :upload_system => 3
    })

    @item.state = 'draft'
  end

  def destroy
    @item = Gwmonitor::Control.find_by_id(params[:id])
    location = public_uri
    _destroy(@item, :success_redirect_uri=>location)
  end

  def closed
    @item = Gwmonitor::Control.find_by_id(params[:id])
    return http_error(404) unless @item
    return http_error(404) if @item.state == 'preparation'
    return authentication_error(403) unless is_creator

    @item.state = 'closed'
    @item.section_code = Site.user_group.code
    @item._commission_state = @before_state

    @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.creater_id = Site.user.code
    @item.creater = Site.user.name
    @item.createrdivision = Site.user_group.name
    @item.createrdivision_id = Site.user_group.code

    @item.save
    location = public_uri
    redirect_to location
  end

  def reopen
    @item = Gwmonitor::Control.find_by_id(params[:id])
    return http_error(404) unless @item
    return http_error(404) if @item.state == 'preparation'
    return authentication_error(403) unless is_creator

    @item.state = 'public'
    @item.section_code = Site.user_group.code
    @item._commission_state = @before_state

    @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.creater_id = Site.user.code
    @item.creater = Site.user.name
    @item.createrdivision = Site.user_group.name
    @item.createrdivision_id = Site.user_group.code

    @item.save
    location = public_uri
    redirect_to location
  end
end
