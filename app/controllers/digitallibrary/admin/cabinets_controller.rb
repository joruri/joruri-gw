class Digitallibrary::Admin::CabinetsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @system = 'digitallibrary'
    @css = ["/_common/themes/gw/css/digitallibrary.css"]
    Page.title = "電子図書"
  end

  def index
    return error_auth unless Digitallibrary::Control.is_admin?

    items = Digitallibrary::Control.distinct.where(view_hide: (params[:state] == "HIDE" ? 0 : 1))
    items = items.where(state: 'public').with_admin_role(Core.user) unless Digitallibrary::Control.is_sysadm?
    @items = items.order(sort_no: :asc, updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit])
  end

  def show
    @item = Digitallibrary::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    _show @item
  end

  def new
    @item = Digitallibrary::Control.new(
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
    )
    return error_auth unless @item.is_admin?
  end

  def create
    @item = Digitallibrary::Control.new(params[:item])
    return error_auth unless @item.is_admin?

    @item.left_index_use = '1'
    @item.upload_graphic_file_size_currently = 0
    @item.upload_document_file_size_currently = 0
    @item.upload_system = 3

    _create @item
  end

  def edit
    @item = Digitallibrary::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    @item.notification = 0 if @item.notification.blank?
  end

  def update
    @item = Digitallibrary::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = Digitallibrary::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    _destroy @item
  end
end
