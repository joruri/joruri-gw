class Gwboard::Admin::FilesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/portal_1column"

  def pre_dispatch
    @css = ["/_common/themes/gw/css/gwbbs_standard.css"]
 end

  def set_params
    if Gwbbs::Control.is_sysadm?
      params[:st] = '2' if params[:st].blank?
      @share_mode = nz(params[:st], '2')
    else
      params[:st] = '1' if params[:st].blank?
      @share_mode = nz(params[:st], '1')
    end
    @sub_title = ''
    @sub_title = '所属用背景画像' if @share_mode == '0'
    @sub_title = '所属用アイコン' if @share_mode == '1'
    @sub_title = '背景画像' if @share_mode == '2'
    @sub_title = 'アイコン' if @share_mode == '3'    
  end
  
  def decision_auth
    return error_auth if !Gwbbs::Control.is_sysadm? && @share_mode != "1"
    return http_error(404) if @share_mode == '0'
  end

  def index
    set_params
    decision_auth
    item = Gwboard::Image.new
    item.and :share, @share_mode
    item.and :section_code, Core.user_group.code unless Gwbbs::Control.is_sysadm? if @share_mode < '2'
    item.page params[:page], params[:limit]
    @items = item.find(:all)

  end

  def new
    set_params
    decision_auth
    item = Gwboard::Image
    @item = item.new({
      :state => 'public' ,
      :section_code => Core.user_group.code,
      :share => @share_mode
    })
  end

  def show
    set_params
    decision_auth
    item = Gwboard::Image
    @item = item.new.find(params[:id])
    return error_auth unless @item
    return error_auth unless @item.section_code == Core.user_group.code unless Gwbbs::Control.is_sysadm? if @item.share < 2
    @share_mode = @item.show_share_states
    _show @item
  end

  #
  def create
    set_params
    decision_auth
    item = Gwboard::Image
    @item = item.new(params[:item])
    @item.state = 'public'
    @item.range_of_use = 0
    @item.section_code = Core.user_group.code unless Gwbbs::Control.is_sysadm?

    group = Gwboard::Group.new
    group.and :state , 'enabled'
    group.and :code ,@item.section_code
    group = group.find(:first)
    @item.section_name = group.code + group.name if group
    _create @item, :success_redirect_uri => gwboard_files_path() + "?st=#{@share_mode}"
  end

  def update
    set_params
    decision_auth
    item = Gwboard::Image
    @item = item.new.find(params[:id])
    @item.attributes = params[:item]
    @item.state = 'public'
    @item.range_of_use = 0

    group = Gwboard::Group.new
    group.and :state , 'enabled'
    group.and :code ,@item.section_code
    group = group.find(:first)
    @item.section_name = group.code + group.name if group
    @item._update = true
    _update @item, :success_redirect_uri => gwboard_files_path() + "?st=#{@share_mode}"
  end

  def destroy
    set_params
    decision_auth
    item = Gwboard::Image
    @item = item.new.find(params[:id])
    _destroy @item, :success_redirect_uri => gwboard_files_path() + "?st=#{@share_mode}"
  end

end
