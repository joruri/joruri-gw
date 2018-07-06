class Gwqa::Admin::MakersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @img_path = "public/_common/modules/gwqa/"
    @system = 'gwqa'
    @css = ["/_common/themes/gw/css/gwfaq.css"]
    Page.title = "質問管理"
  end

  def index
    return error_auth if !Gwfaq::Control.is_admin? && !Gwqa::Control.is_admin?

    @faq_items = Gwfaq::Control.where(view_hide: (params[:state] == "HIDE" ? 0 : 1))
      .tap {|c| break c.where(state: 'public').with_admin_role(Core.user) unless Gwfaq::Control.is_sysadm? }
      .order(sort_no: :asc, updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit]).distinct

    @qa_items = Gwqa::Control.where(view_hide: (params[:state] == "HIDE" ? 0 : 1))
      .tap {|c| break c.where(state: 'public').with_admin_role(Core.user) unless Gwqa::Control.is_sysadm? }
      .order(sort_no: :asc, updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit]).distinct
  end

  def show
    @item = Gwqa::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    _show @item
  end

  def new
    @item = Gwqa::Control.new({
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
      :help_display => '1' ,  #ヘルプを表示しない
      :create_section => '' , #掲示板管理者用画面を使用する
      :categoey_view  => 1 ,
      :categoey_view_line => 0 ,
      :group_view  => 1 ,
      :upload_system => 3 ,   #添付ファイル機能をpublic配下に保存する設定
      :monthly_view => 1 ,
      :monthly_view_line => 6 ,
      :default_limit => '20'
    })
    return error_auth unless @item.is_admin?
  end

  def create
    @item = Gwqa::Control.new(maker_params)
    return error_auth unless @item.is_admin?

    @item.left_index_use = '1'
    @item.upload_graphic_file_size_currently = 0
    @item.upload_document_file_size_currently = 0
    @item.categoey_view_line = 0
    @item.upload_system = 3

    _create @item, :success_redirect_uri => "/gwfaq/controls"
  end

  def edit
    @item = Gwqa::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    @item.notification = 0 if @item.notification.blank?
  end

  def update
    @item = Gwqa::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    @item.attributes = maker_params
    @item.categoey_view_line = 0

    _update @item, :success_redirect_uri => "/gwfaq/controls"
  end

  def destroy
    @item = Gwqa::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    _destroy @item, :success_redirect_uri => "/gwfaq/controls"
  end
private
  def maker_params
    params.require(:item).permit(:state, :create_section, :recognize , :title,
      :default_limit , :category1_name, :category, :notification,
      :upload_graphic_file_size_capacity, :upload_graphic_file_size_capacity_unit,
      :upload_document_file_size_capacity, :upload_document_file_size_capacity_unit,
      :upload_graphic_file_size_max, :upload_document_file_size_max,
      :sort_no, :view_hide, :caption, :left_index_pattern,
      :categoey_view , :group_view, :monthly_view, :monthly_view_line,
      :admingrps_json, :adms_json,
      :editors_json,  :sueditors_json,
      :readers_json, :sureaders_json,
      :dbname, :other_system_link, :left_index_use,
      :upload_graphic_file_size_currently, :upload_document_file_size_currently,
      :banner, :left_banner, :help_display, :help_url, :help_admin_url,
      :admingrps => [:gid], :adms => [:gid],
      :editors => [:gid], :sueditors => [:gid],
      :readers => [:gid], :sureaders => [:gid])
  end
end
