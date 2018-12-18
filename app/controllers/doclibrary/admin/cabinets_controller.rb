class Doclibrary::Admin::CabinetsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @img_path = "public/doclibrary/docs/"
    @system = 'doclibrary'
    @css = ["/_common/themes/gw/css/doclibrary.css"]
    @cabinet_title = '書庫'
    Page.title = "書庫"
  end

  def index
    return error_auth unless Doclibrary::Control.is_admin?

    @items = Doclibrary::Control.where(view_hide: (params[:state] == "HIDE" ? 0 : 1))
      .tap {|c| break c.where(state: 'public').with_admin_role(Core.user) unless Doclibrary::Control.is_sysadm? }
      .order(sort_no: :asc, updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit]).distinct
  end

  def show
    @item = Doclibrary::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    _show @item
  end

  def new
    @item = Doclibrary::Control.new({
      :state => 'public' ,
      :published_at => Core.now ,
      :importance => '1' ,
      :category => '1' ,
      :left_index_use => '1',
      :category1_name => 'ルートフォルダ' ,
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
      :default_limit => '20'
    })
    return error_auth unless @item.is_admin?
  end

  def create
    @item = Doclibrary::Control.new(cabinet_params)
    return error_auth unless @item.is_admin?

    @item.left_index_use = '1'
    @item.upload_graphic_file_size_currently = 0
    @item.upload_document_file_size_currently = 0
    @item.upload_system = 3

    if @item.save
      @item.group_folders.build.class.delay.sync_group_folders(@item.id,'public')
      redirect_to doclibrary_cabinets_path
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @item = Doclibrary::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    @item.notification = 0 if @item.notification.blank?
  end

  def update
    @item = Doclibrary::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    @item.attributes = cabinet_params

    _update @item
  end

  def destroy
    @item = Doclibrary::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    _destroy @item
  end
private

  def cabinet_params
    params.require(:item).permit(:state, :create_section, :recognize , :title,
      :default_limit , :importance, :default_folder, :category1_name, :category, :notification,
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
      :help_admin_url, :form_name, :special_link,
      :admingrps => [:gid], :adms => [:gid],
      :editors => [:gid], :sueditors => [:gid],
      :readers => [:gid], :sureaders => [:gid])
  end

end
