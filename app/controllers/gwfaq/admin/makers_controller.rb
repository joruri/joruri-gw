# -*- encoding: utf-8 -*-
class Gwfaq::Admin::MakersController < Gw::Controller::Admin::Base

  layout "admin/template/portal_1column"


  include Gwboard::Controller::Scaffold
  include Gwfaq::Model::DbnameAlias
  include Gwboard::Controller::Authorize
  include Gwboard::Controller::Message

  def initialize_scaffold
    @img_path = "public/_common/modules/gwfaq/"
    @system = 'gwfaq'
    @css = ["/_common/themes/gw/css/gwfaq.css"]
    Page.title = "質問管理"
  end

  def index
    faq_index
    qa_index
  end

  def faq_index
    admin_flags('_menu')
    return redirect_to("/#{@system}/") unless @is_admin
    if @is_sysadm
      faq_sysadm_index
    else
      faq_bbsadm_index
    end
  end

  def faq_sysadm_index
    item = Gwfaq::Control.new
    item.and :view_hide, (params[:state] == "HIDE" ? 0 : 1)
    item.page params[:page], params[:limit]
    @faq_items = item.find(:all, :order => 'sort_no, updated_at DESC')
  end

  def faq_bbsadm_index
    item = Gwfaq::Control.new
    item.and "gwfaq_controls.state", 'public'
    item.and "gwfaq_controls.view_hide", (params[:state] == "HIDE" ? 0 : 1)
    item.and do |d|
      d.or do |d2|
        d2.and "gwfaq_adms.user_code", Core.user.code
      end
      d.or do |d2|
        d2.and "gwfaq_adms.user_id", 0
        d2.and "gwfaq_adms.group_code", Site.user_group.parent_tree.map{|g| g.code}
      end
    end
    item.join "INNER JOIN gwfaq_adms ON gwfaq_controls.id = gwfaq_adms.title_id"
    item.page  params[:page], params[:limit]
    @faq_items = item.find(:all, :order => 'sort_no, updated_at DESC', :group => 'gwfaq_controls.id')
  end

  def qa_index
    admin_flags('_menu')
    return redirect_to("/#{@system}/") unless @is_admin
    if @is_sysadm
      qa_sysadm_index
    else
      qa_bbsadm_index
    end
  end

  def qa_sysadm_index
    item = Gwqa::Control.new
    item.and :view_hide, (params[:state] == "HIDE" ? 0 : 1)
    item.page params[:page], params[:limit]
    @qa_items = item.find(:all, :order => 'sort_no, updated_at DESC')
  end

  def qa_bbsadm_index
    item = Gwqa::Control.new
    item.and "gwqa_controls.state",'public'
    item.and "gwqa_controls.view_hide", (params[:state] == "HIDE" ? 0 : 1)
    item.and do |d|
      d.or do |d2|
        d2.and "gwqa_adms.user_code", Core.user.code
      end
      d.or do |d2|
        d2.and "gwqa_adms.user_id", 0
        d2.and "gwqa_adms.group_code", Site.user_group.parent_tree.map{|g| g.code}
      end
    end
    item.join "INNER JOIN gwqa_adms ON gwqa_controls.id = gwqa_adms.title_id"
    item.page params[:page], params[:limit]
    @qa_items = item.find(:all, :order => 'sort_no, updated_at DESC', :group => 'gwqa_controls.id')
  end

  def show
    admin_flags(params[:id])
    return redirect_to("/#{@system}/") unless @is_admin

    @item = Gwfaq::Control.find(params[:id])
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

  def get_wallpapers
    wallpapers = nil
    wallpaper = Gw::IconGroup.find_by_name(@system)
    unless wallpaper.blank?
      item = Gw::Icon.new
      item.and :icon_gid, wallpaper.id
      wallpapers = item.find(:all,:order => 'idx')
    end
    return wallpapers
  end

  def get_csses
    csses = nil
    css = Gw::IconGroup.find_by_name('GWBBS_CSS')
    unless css.blank?
      item = Gw::Icon.new
      item.and :icon_gid, css.id
      csses = item.find(:all,:order => 'idx')
    end
    return csses
  end


  def edit
    admin_flags(params[:id])
    return redirect_to("/#{@system}/") unless @is_admin

    @wallpapers = get_wallpapers
    @csses = get_csses
    @item = Gwfaq::Control.find(params[:id])
    return http_error(404) unless @item
    @image_message = ret_image_message
    @document_message = ret_document_message
    @item.notification = 0 if @item.notification.blank?
  end

  def new
    admin_flags(params[:id])
    return redirect_to("/#{@system}/") unless @is_admin

    @wallpapers = get_wallpapers
    @csses = get_csses

    @item = Gwfaq::Control.new({
      :state => 'public' ,
      :published_at => Time.now ,
      :importance => '1' ,
      :category => '1' ,
      :left_index_use => '1', #左サイドメニュー
      :category1_name => '分類' ,
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
      :notification => 1 ,  #記事更新時連絡機能を利用する
      :upload_system => 3 ,   #添付ファイル機能をpublic配下に保存する設定
      :help_display => '1' ,  #ヘルプを表示しない
      :create_section => '' , #掲示板管理者用画面を使用する
      :categoey_view  => 1 ,
      :categoey_view_line => 0 ,
      :group_view  => 0 ,
      :monthly_view => 1 ,
      :monthly_view_line => 6 ,
      :default_limit => '20'
    })
  end

  def create
    admin_flags(params[:id])

    @item = Gwfaq::Control.new(params[:item])
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
    @item.categoey_view_line = 0
    #
    @item.upload_system = 3

    groups = JsonParser.new.parse(@item.readers_json)
    if groups.length == 0
      @item.readers_json = @item.editors_json
    end

    _create @item, :success_redirect_uri => "/gwfaq/controls"
  end

  def update
    admin_flags(params[:id])

    @item = Gwfaq::Control.find(params[:id])
    @item.attributes = params[:item]
    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.editor_id = Site.user.code unless Site.user.code.blank?
    @item.editor = Site.user.name unless Site.user.name.blank?
    @item.editordivision = Site.user_group.name unless Site.user_group.name.blank?
    @item.editordivision_id = Site.user_group.code unless Site.user_group.code.blank?

    groups = JsonParser.new.parse(@item.readers_json)
    if groups.length == 0
      @item.readers_json = @item.editors_json
    end

    _update @item, :success_redirect_uri => "/gwfaq/controls"
  end

  def destroy
    @item = Gwfaq::Control.find(params[:id])
    _destroy @item, :success_redirect_uri => "/gwfaq/controls"
  end

end
