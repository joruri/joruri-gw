# -*- encoding: utf-8 -*-
class Gwbbs::Admin::MakersController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwbbs::Model::DbnameAlias
  include Gwboard::Controller::Authorize
  include Gwboard::Controller::Message

  layout "admin/template/portal_1column"

  def initialize_scaffold
    @img_path = "public/_common/modules/gwbbs/"
    @system = 'gwbbs'
    @css = ["/_common/themes/gw/css/bbs.css"]
    Page.title = "掲示板"
    params[:limit] = 100
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

    @item = Gwbbs::Control.find(params[:id])
    return http_error(404) unless @item
    @admingrps = JsonParser.new.parse(@item.admingrps_json) if @item.admingrps_json
    @adms = JsonParser.new.parse(@item.adms_json) if @item.adms_json
    @editors = JsonParser.new.parse(@item.editors_json) if @item.editors_json
    @readers = JsonParser.new.parse(@item.readers_json) if @item.readers_json
    @sueditors = JsonParser.new.parse(@item.sueditors_json) if @item.sueditors_json
    @sureaders = JsonParser.new.parse(@item.sureaders_json) if @item.sureaders_json
    @image_message = ret_image_message
    @document_message = ret_document_message
    @item.banner_position = '' if @item.banner_position.blank?
    @item.css = '#FFFCF0' if @item.css.blank?
    @item.font_color = '#000000' if @item.font_color.blank?
    _show @item
  end

  def new
    admin_flags(params[:id])
    return http_error(403) unless @is_admin

    @bg_colors = Gwboard::Bgcolor.find(:all,:conditions=>'content_id=0',:order=>'id')
    @font_colors = Gwboard::Bgcolor.find(:all,:conditions=>'content_id=1',:order=>'id')

    @item = Gwbbs::Control.new({
      :state => 'public',
      :published_at => Time.now,
      :recognize => 0,
      :importance => '1', #重要度使用
      :category => '1', #分類使用
      :left_index_use => '1', #左サイドメニュー
      :left_index_pattern => 0,
      :category1_name => '分類',
      :default_published => 3,
      :doc_body_size_capacity => 30, #記事本文総容量制限初期値30MB
      :doc_body_size_currently => 0, #記事本文現在の利用サイズ初期値0
      :upload_graphic_file_size_capacity => 10, #初期値10MB
      :upload_graphic_file_size_capacity_unit => 'MB',
      :upload_document_file_size_capacity => 30,  #初期値30MB
      :upload_document_file_size_capacity_unit => 'MB',
      :upload_graphic_file_size_max => 3, #初期値3MB
      :upload_document_file_size_max => 10, #初期値10MB
      :upload_graphic_file_size_currently => 0,
      :upload_document_file_size_currently => 0,
      :sort_no => 0 ,
      :view_hide => 1 ,
      :categoey_view  => 1 ,
      :categoey_view_line => 0 ,
      :group_view  => 1 ,
      :help_display => '1' ,  #ヘルプを表示しない
      :create_section_flag => 'section_code' , #掲示板管理者用画面を使用する
      :upload_system => 3 ,   #添付ファイル機能をpublic配下に保存する設定
      :one_line_use => 1 ,  #１行コメント使用
      :notification => 1 ,  #記事更新時連絡機能を利用する
      :restrict_access => 0 ,
      :monthly_view => 1 ,
      :monthly_view_line => 6 ,
      :limit_date => 'none',
      :banner_position => '',
      :css => '#FFFCF0' ,
      :font_color => '#000000' ,
      :default_limit => '20'
    })
  end

  def edit
    admin_flags(params[:id])
    return http_error(403) unless @is_admin

    @bg_colors = Gwboard::Bgcolor.find(:all,:conditions=>'content_id=0',:order=>'id')
    @font_colors = Gwboard::Bgcolor.find(:all,:conditions=>'content_id=1',:order=>'id')

    @item = Gwbbs::Control.find(params[:id])
    return http_error(404) unless @item
    @image_message = ret_image_message
    @document_message = ret_document_message
    @item.create_section_flag = 'section_code' if @item.create_section_flag.blank? unless @item.create_section.blank? #実装前に作成された掲示板の対応
    @item.preview_mode = false  if @item.preview_mode.blank?
    @item.banner_position = '' if @item.banner_position.blank?
    @item.css = '#FFFCF0' if @item.css.blank?
    @item.font_color = '#000000' if @item.font_color.blank?
  end

  def create
    admin_flags(params[:id])
    return http_error(403) unless @is_admin

    @item = Gwbbs::Control.new(params[:item])
    @item.createdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.creater_id = Core.user.code unless Core.user.code.blank?
    @item.creater = Core.user.name unless Core.user.name.blank?
    @item.createrdivision = Core.user_group.name unless Core.user_group.name.blank?
    @item.createrdivision_id = Core.user_group.code unless Core.user_group.code.blank?

    @item.editor_id = Core.user.code unless Core.user.code.blank?
    @item.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?
    @item.upload_graphic_file_size_currently = 0
    @item.upload_document_file_size_currently = 0
    @item.categoey_view_line = 0

    #
    @item.upload_system = 3

    @item._makers = true
    if @item.preview_mode
      _create @item, :success_redirect_uri => gwbbs_makers_path
    else
      _create @item, :success_redirect_uri => gwbbs_makers_path
    end
  end

  def update
    admin_flags(params[:id])
    return http_error(403) unless @is_admin

    @item = Gwbbs::Control.find(params[:id])
    @item.attributes = params[:item]
    @item.editdate = Time.now.strftime("%Y-%m-%d %H:%M")
    @item.editor_id = Core.user.code unless Core.user.code.blank?
    @item.editor = Core.user.name unless Core.user.name.blank?
    @item.editordivision = Core.user_group.name unless Core.user_group.name.blank?
    @item.editordivision_id = Core.user_group.code unless Core.user_group.code.blank?
    @item.categoey_view_line = 0

    @item._makers = true
    if @item.preview_mode
      _update @item, :success_redirect_uri => gwbbs_maker_path(@item)
    else
      _update @item, :success_redirect_uri => gwbbs_maker_path(@item)
    end
  end

  def destroy
    admin_flags(params[:id])
    return http_error(403) unless @is_admin

    @item = Gwbbs::Control.find(params[:id])
    begin
    @item.image_delete_all(@img_path) if @item  #画像フォルダ削除
    rescue
    end
    @title = Gwbbs::Control.find(params[:id])
    destroy_categories
    destroy_docs
    destroy_comments
    destroy_atacched_files
    destroy_files
    _destroy @item, :success_redirect_uri => gwbbs_makers_path
  end

  def design_publish
    admin_flags(params[:id])
    return http_error(403) unless @is_admin
    @item = Gwbbs::Control.find(params[:id])
    return http_error(404) if @item.blank?
    @item.preview_mode = false
    @item._design_publish = true
    _update @item
  end

  def sysadm_index
    item = Gwbbs::Control.new
    item.and :view_hide, (params[:state] == "HIDE" ? 0 : 1)
    item.and "sql", "create_section IS NULL" unless params[:state] == "SECTION"
    item.and "sql", "create_section IS NOT NULL" if params[:state] == "SECTION"
    item.page params[:page], params[:limit]
    @items = item.find(:all, :order => 'sort_no, updated_at DESC')
    _index @items
  end

  def bbsadm_index
    item = Gwbbs::Control.new
    item.and "gwbbs_controls.state", 'public'
    item.and "gwbbs_controls.view_hide", (params[:state] == "HIDE" ? 0 : 1)
    item.and do |d|
      d.or do |d2|
        d2.and "gwbbs_adms.user_code", Core.user.code
      end
      d.or do |d2|
        d2.and "gwbbs_adms.user_id", 0
        d2.and "gwbbs_adms.group_code", Site.user_group.parent_tree.map{|g| g.code}
      end
    end
    item.join "INNER JOIN gwbbs_adms ON gwbbs_controls.id = gwbbs_adms.title_id"
    item.page  params[:page], params[:limit]
    @items = item.find(:all, :order => 'sort_no, updated_at DESC', :group => 'gwbbs_controls.id')
    _index @items
  end

  def sql_where
    sql = Condition.new
    sql.and "title_id", @item.id
    return sql.where
  end

  def destroy_categories
    item = gwbbs_db_alias(Gwbbs::Category)
    item.destroy_all(sql_where)
    Gwbbs::Category.remove_connection
  end

  def destroy_docs
    item = gwbbs_db_alias(Gwbbs::Doc)
    item.destroy_all(sql_where)
    Gwbbs::Doc.remove_connection
  end

  def destroy_comments
    item = gwbbs_db_alias(Gwbbs::Comment)
    item.destroy_all(sql_where)
    Gwbbs::Comment.remove_connection
  end

  def destroy_atacched_files
    item = gwbbs_db_alias(Gwbbs::File)
    item.destroy_all(sql_where)
    Gwbbs::File.remove_connection
  end

  def destroy_files
    item = gwbbs_db_alias(Gwbbs::DbFile)
    item.destroy_all(sql_where)
    Gwbbs::DbFile.remove_connection
  end

end
