class Digitallibrary::Admin::CabinetsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @img_path = "public/digitallibrary/docs/"
    @system = 'digitallibrary'
    @css = ["/_common/themes/gw/css/digitallibrary.css"]
    Page.title = "電子図書"
  end

  def index
    return error_auth unless Digitallibrary::Control.is_admin?

    @items = Digitallibrary::Control.where(view_hide: (params[:state] == "HIDE" ? 0 : 1))
      .tap {|c| break c.where(state: 'public').with_admin_role(Core.user) unless Digitallibrary::Control.is_sysadm? }
      .order(sort_no: :asc, updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit]).distinct
  end

  def show
    @item = Digitallibrary::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    _show @item
  end

  def new
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
    return error_auth unless @item.is_admin?

    load_theme_settings
  end

  def create
    dump params[:item].each{|k, v| dump k}
    @item = Digitallibrary::Control.new(cabinet_params)
    return error_auth unless @item.is_admin?

    @item.left_index_use = '1'
    @item.upload_graphic_file_size_currently = 0
    @item.upload_document_file_size_currently = 0
    @item.upload_system = 3

    load_theme_settings

    _create @item
  end

  def edit
    @item = Digitallibrary::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    @item.notification = 0 if @item.notification.blank?

    load_theme_settings
  end

  def update
    @item = Digitallibrary::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    @item.attributes = cabinet_params

    load_theme_settings

    _update @item
  end

  def destroy
    @item = Digitallibrary::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    _destroy @item
  end

  private

  def load_theme_settings
    @wallpapers = get_wallpapers
    @csses = get_csses
  end

  def get_wallpapers
    wallpapers = nil
    wallpaper = Gw::IconGroup.find_by(name: 'digitallibrary')
    unless wallpaper.blank?
      item = Gw::Icon.new
      item.and :icon_gid, wallpaper.id
      wallpapers = item.find(:all,:order => 'idx')
    end
    return wallpapers
  end

  def get_csses
    csses = nil
    css = Gw::IconGroup.find_by(name: 'digitallibrary_CSS')
    unless css.blank?
      item = Gw::Icon.new
      item.and :icon_gid, css.id
      csses = item.find(:all,:order => 'idx')
    end
    return csses
  end

private

  def cabinet_params
    params.require(:item).permit(:state, :create_section, :recognize , :title,
      :default_limit , :importance,  :category1_name, :category,
      :separator_str1, :separator_str2, :notification,
      :upload_graphic_file_size_capacity, :upload_graphic_file_size_capacity_unit,
      :upload_document_file_size_capacity, :upload_document_file_size_capacity_unit,
      :upload_graphic_file_size_max, :upload_document_file_size_max,
      :sort_no, :view_hide, :caption,
      :admingrps_json, :adms_json,
      :editors_json,  :sueditors_json,
      :readers_json, :sureaders_json,
      :dbname, :other_system_link, :left_index_use,
      :upload_graphic_file_size_currently, :upload_document_file_size_currently,
      :banner, :left_banner, :left_index_bg_color, :help_display, :help_url,
      :help_admin_url,
      :admingrps => [:gid], :adms => [:gid],
      :editors => [:gid], :sueditors => [:gid],
      :readers => [:gid], :sureaders => [:gid])
  end

end
