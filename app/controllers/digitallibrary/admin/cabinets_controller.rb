# -*- encoding: utf-8 -*-
class Digitallibrary::Admin::CabinetsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Digitallibrary::Model::DbnameAlias
  include Gwboard::Controller::Authorize
  include Gwboard::Controller::Message

  layout "admin/template/portal_1column"

  def initialize_scaffold
    @img_path = "public/digitallibrary/docs/"
    @system = 'digitallibrary'
    @css = ["/_common/themes/gw/css/digitallibrary.css"]
    Page.title = "電子図書"
  end


  def index
    admin_flags('_menu')
    return http_error(403) unless @is_admin
    if @is_sysadm
      sysadm_index
    else
      bbsadm_index
    end
  end

  def show
    admin_flags(params[:id])
    return http_error(403) unless @is_admin

    @item = Digitallibrary::Control.find(params[:id])
    return http_error(404) unless @item
    @admingrps = JsonParser.new.parse(@item.admingrps_json) if @item.admingrps_json
    @adms = JsonParser.new.parse(@item.adms_json) if @item.adms_json
    @editors = JsonParser.new.parse(@item.editors_json) if @item.editors_json
    @readers = JsonParser.new.parse(@item.readers_json) if @item.readers_json
    @sueditors = JsonParser.new.parse(@item.sueditors_json) if @item.sueditors_json
    @sureaders = JsonParser.new.parse(@item.sureaders_json) if @item.sureaders_json
    @image_message = ret_image_message
    @document_message = ret_document_message
    _show @item
  end

  def new
    admin_flags(params[:id])
    return http_error(403) unless @is_admin

    @wallpapers = get_wallpapers
    @csses = get_csses

    @item = Digitallibrary::Control.new({
      :state => 'public' ,
      :published_at => Core.now ,
      :importance => '1' ,
      :category => '0' ,
      :left_index_use => '1',
      :category1_name => '見出し' ,
      :recognize => '0' ,
      :default_published => 3,
      :upload_graphic_file_size_capacity => 10,
      :upload_graphic_file_size_capacity_unit => 'MB',
      :upload_document_file_size_capacity => 30,
      :upload_document_file_size_capacity_unit => 'MB',
      :upload_graphic_file_size_max => 3,
      :upload_document_file_size_max => 10,
      :upload_graphic_file_size_currently => 0,
      :upload_document_file_size_currently => 0,
      :sort_no => 0 ,
      :view_hide => 1 ,
      :upload_system => 3 ,
      :notification => 1 ,
      :help_display => '1' ,
      :create_section => '' ,
      :categoey_view  => 1 ,
      :categoey_view_line => 0 ,
      :monthly_view => 1 ,
      :monthly_view_line => 6 ,
      :separator_str1 => '.',
      :separator_str2 => '.',
      :default_limit => '20'
    })
  end

  def edit
    admin_flags(params[:id])
    return http_error(403) unless @is_admin

    @wallpapers = get_wallpapers
    @csses = get_csses
    @item = Digitallibrary::Control.find(params[:id])
    return http_error(404) unless @item
    @image_message = ret_image_message
    @document_message = ret_document_message
    @item.notification = 0 if @item.notification.blank?
  end

  def create
    admin_flags(params[:id])
    return http_error(403) unless @is_admin

    @item = Digitallibrary::Control.new(params[:item])
    @item.left_index_use = '1'
    @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.creater_id = Site.user.code unless Site.user.code.blank?
    @item.creater = Site.user.name unless Site.user.name.blank?
    @item.createrdivision = Site.user_group.name unless Site.user_group.name.blank?
    @item.createrdivision_id = Site.user_group.code unless Site.user_group.code.blank?

    @item.editor_id = Site.user.code unless Site.user.code.blank?
    @item.editordivision_id = Site.user_group.code unless Site.user_group.code.blank?
    @item.upload_graphic_file_size_currently = 0
    @item.upload_document_file_size_currently = 0

    @item.upload_system = 3
    _create_doclib(@item, :system_name => 'digitallibrary')
  end

  def update
    admin_flags(params[:id])
    return http_error(403) unless @is_admin

    @item = Digitallibrary::Control.find(params[:id])
    @item.attributes = params[:item]
    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.editor_id = Site.user.code unless Site.user.code.blank?
    @item.editor = Site.user.name unless Site.user.name.blank?
    @item.editordivision = Site.user_group.name unless Site.user_group.name.blank?
    @item.editordivision_id = Site.user_group.code unless Site.user_group.code.blank?
    @title = @item
    seq_name_update_all
    _update_doclib @item
  end

  def destroy
    @item = Digitallibrary::Control.find(params[:id])
    _destroy @item
  end

  def sysadm_index
    item = Digitallibrary::Control.new
    item.and :view_hide, (params[:state] == "HIDE" ? 0 : 1)
    item.page params[:page], params[:limit]
    @items = item.find(:all, :order => 'sort_no, updated_at DESC')
    _index @items
  end

  def bbsadm_index
    item = Digitallibrary::Control.new
    item.and "digitallibrary_controls.state", 'public'
    item.and "digitallibrary_controls.view_hide", (params[:state] == "HIDE" ? 0 : 1)
    item.and do |d|
      d.or do |d2|
        d2.and "digitallibrary_adms.user_code", Site.user.code
      end
      d.or do |d2|
        d2.and "digitallibrary_adms.user_id", 0
        d2.and "digitallibrary_adms.group_code", Site.user_group.parent_tree.map{|g| g.code}
      end
    end
    item.join "INNER JOIN digitallibrary_adms ON digitallibrary_controls.id = digitallibrary_adms.title_id"
    item.page params[:page], params[:limit]
    @items = item.find(:all, :order => 'sort_no, updated_at DESC', :group => 'digitallibrary_controls.id')
    _index @items
  end

  def get_wallpapers
    wallpapers = nil
    wallpaper = Gw::IconGroup.find_by_name('digitallibrary')
    unless wallpaper.blank?
      item = Gw::Icon.new
      item.and :icon_gid, wallpaper.id
      wallpapers = item.find(:all,:order => 'idx')
    end
    return wallpapers
  end

  def get_csses
    csses = nil
    css = Gw::IconGroup.find_by_name('digitallibrary_CSS')
    unless css.blank?
      item = Gw::Icon.new
      item.and :icon_gid, css.id
      csses = item.find(:all,:order => 'idx')
    end
    return csses
  end

end
