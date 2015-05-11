class Gwbbs::Admin::MakersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @is_gw_admin = Gw.is_admin_admin?
    @system = 'gwbbs'
    @css = ["/_common/themes/gw/css/bbs.css"]
    Page.title = "掲示板"
    params[:limit] = 100
  end

  def index
    return error_auth unless Gwbbs::Control.is_admin?

    items = Gwbbs::Control.distinct.where(view_hide: (params[:state] == "HIDE" ? 0 : 1))
    items = items.where(create_section: nil) if Gwbbs::Control.is_sysadm? && params[:state] != "SECTION"
    items = items.where.not(create_section: nil) if Gwbbs::Control.is_sysadm? && params[:state] == "SECTION"
    items = items.where(state: 'public').with_admin_role(Core.user) unless Gwbbs::Control.is_sysadm?
    @items = items.order(sort_no: :asc, updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = Gwbbs::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    @item.banner_position = '' if @item.banner_position.blank?
    @item.css = '#FFFCF0' if @item.css.blank?
    @item.font_color = '#000000' if @item.font_color.blank?

    _show @item
  end

  def new
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
    return error_auth unless @item.is_admin?

    load_theme_settings
  end

  def create
    @item = Gwbbs::Control.new(params[:item])
    return error_auth unless @item.is_admin?

    load_theme_settings

    @item.upload_graphic_file_size_currently = 0
    @item.upload_document_file_size_currently = 0
    @item.categoey_view_line = 0
    @item.upload_system = 3

    @item._update = false
    @item._makers = true

    if @item.preview_mode
      _create @item, :success_redirect_uri => gwbbs_makers_path
    else
      _create @item, :success_redirect_uri => gwbbs_makers_path
    end
  end

  def edit
    @item = Gwbbs::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    load_theme_settings

    @item.create_section_flag = 'section_code' if @item.create_section_flag.blank? unless @item.create_section.blank? #実装前に作成された掲示板の対応
    @item.preview_mode = false  if @item.preview_mode.blank?
    @item.banner_position = '' if @item.banner_position.blank?
    @item.css = '#FFFCF0' if @item.css.blank?
    @item.font_color = '#000000' if @item.font_color.blank?
  end

  def update
    @item = Gwbbs::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    load_theme_settings

    @item.attributes = params[:item]
    @item.categoey_view_line = 0
    @item._update = true
    @item._makers = true

    if @item.preview_mode
      _update @item, :success_redirect_uri => gwbbs_maker_path(@item)
    else
      _update @item, :success_redirect_uri => gwbbs_maker_path(@item)
    end
  end

  def destroy
    @item = Gwbbs::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    _destroy @item, :success_redirect_uri => gwbbs_makers_path
  end

  def design_publish
    @item = Gwbbs::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    @item.preview_mode = false
    @item._design_publish = true

    _update @item
  end

  private

  def load_theme_settings
    @bg_colors = Gwboard::Bgcolor.where(content_id: 1).order(:id)
    @font_colors = Gwboard::Bgcolor.where(content_id: 1).order(:id)
    @icons = get_icons
    @wallpapers = get_wallpapers
  end

  def get_wallpapers
    sql = Condition.new
    sql.or {|d|
      d.and :share , 0
      d.and :range_of_use , 0
      d.and :section_code , Core.user_group.code
    }
    sql.or {|d|
      d.and :share , 0
      d.and :range_of_use , 10
      d.and :section_code , Core.user_group.code
    }
    sql.or {|d|
      d.and :share , 2
      d.and :range_of_use , 0
    }
    sql.or {|d|
      d.and :share , 2
      d.and :range_of_use , 10
    }
    item = Gwboard::Image.new
    return item.find(:all, :conditions => sql.where, :order=>'share, id')
  end

  def get_icons
    sql = Condition.new
    sql.or {|d|
      d.and :share , 1
      d.and :range_of_use , 0
      d.and :section_code , Core.user_group.code
    }
    sql.or {|d|
      d.and :share , 1
      d.and :range_of_use , 10
      d.and :section_code , Core.user_group.code
    }
    sql.or {|d|
      d.and :share , 3
      d.and :range_of_use , 0
    }
    sql.or {|d|
      d.and :share , 3
      d.and :range_of_use , 10
    }
    item = Gwboard::Image.new
    return item.find(:all, :conditions => sql.where, :order=>'share, id')
  end
end
