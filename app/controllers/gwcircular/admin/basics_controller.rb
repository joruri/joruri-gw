class Gwcircular::Admin::BasicsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/gwcircular"

  def pre_dispatch
    return error_auth unless Gwcircular::Control.is_admin?

    @css = ["/_common/themes/gw/css/circular.css"]
    @public_uri = "/gwcircular/basics"

    Page.title = "基本情報設定"
    params[:limit] = 100
  end

  def index
    @items = Gwcircular::Control.where(view_hide: (params[:state] == "HIDE" ? 0 : 1))
      .tap {|c| break c.where(state: 'public').with_admin_role(Core.user) unless Gwcircular::Control.is_sysadm? }
      .order(sort_no: :asc, updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit]).distinct
  end

  def show
    @item = Gwcircular::Control.find(params[:id])

    @item.banner_position = '' if @item.banner_position.blank?
    @item.css = '#FFFCF0' if @item.css.blank?
    @item.font_color = '#000000' if @item.font_color.blank?
    begin
      @icon_item = Gwboard::Image.find(@item.icon_id)
      @wallpaper_item = Gwboard::Image.find(@item.wallpaper_id)
    rescue
    end
    _show @item
  end

  def new
    @item = Gwcircular::Control.new({
      :state => 'public',
      :published_at => Time.now,
      :recognize => 0,
      :importance => '1', #重要度使用
      :category => '1', #分類使用
      :left_index_use => '1', #左サイドメニュー
      :left_index_pattern => 0,
      :category1_name => '分類',
      :default_published => 3,
      :doc_body_size_capacity => 100, #記事本文総容量制限初期値30MB
      :doc_body_size_currently => 0, #記事本文現在の利用サイズ初期値0
      :upload_graphic_file_size_capacity => 10, #初期値10MB
      :upload_graphic_file_size_capacity_unit => 'GB',
      :upload_document_file_size_capacity => 10,  #初期値30MB
      :upload_document_file_size_capacity_unit => 'GB',
      :upload_graphic_file_size_max => 50, #初期値3MB
      :upload_document_file_size_max => 50, #初期値10MB
      :upload_graphic_file_size_currently => 0,
      :upload_document_file_size_currently => 0,
      :commission_limit => 200 ,
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

  def create
    @item = Gwcircular::Control.new(basic_params)
    @item.upload_graphic_file_size_currently = 0
    @item.upload_document_file_size_currently = 0
    @item.categoey_view_line = 0
    @item.doc_body_size_capacity = 100
    @item.doc_body_size_currently = 0

    @item.upload_system = 3

    groups = JSON.parse(@item.readers_json)
    if groups.length == 0
      @item.readers_json = @item.editors_json
    end

    _create @item
  end

  def edit
    @item = Gwcircular::Control.find(params[:id])

    @item.create_section_flag = 'section_code' if @item.create_section_flag.blank? unless @item.create_section.blank? #実装前に作成された掲示板の対応
    @item.preview_mode = false  if @item.preview_mode.blank?
    @item.banner_position = '' if @item.banner_position.blank?
    @item.css = '#FFFCF0' if @item.css.blank?
    @item.font_color = '#000000' if @item.font_color.blank?
  end

  def update
    @item = Gwcircular::Control.find(params[:id])
    @item.attributes = basic_params
    @item.categoey_view_line = 0

    groups = JSON.parse(@item.readers_json)
    if groups.length == 0
      @item.readers_json = @item.editors_json
    end

    if @item.preview_mode
      _update @item, :success_redirect_uri => @item.adm_show_path
    else
      _update @item
    end
  end

  def destroy
    @item = Gwcircular::Control.find(params[:id])
    _destroy @item
  end

private

  def basic_params
    params.require(:item).permit(:state, :create_section, :recognize , :title,
      :default_published, :commission_limit, :limit_date,
      :upload_graphic_file_size_capacity, :upload_graphic_file_size_capacity_unit,
      :upload_document_file_size_capacity, :upload_document_file_size_capacity_unit,
      :upload_graphic_file_size_max, :upload_document_file_size_max,
      :admingrps_json, :adms_json,
      :editors_json,  :sueditors_json,
      :readers_json, :sureaders_json,
      :admingrps => [:gid], :adms => [:gid],
      :editors => [:gid], :sueditors => [:gid],
      :readers => [:gid], :sureaders => [:gid])
  end

end
