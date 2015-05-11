class Gwqa::Admin::MakersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @system = 'gwqa'
    @css = ["/_common/themes/gw/css/gwfaq.css"]
    Page.title = "質問管理"
  end

  def index
    return error_auth if !Gwfaq::Control.is_admin? && !Gwqa::Control.is_admin?

    @faq_items = load_control_items(Gwfaq::Control)
    @qa_items = load_control_items(Gwqa::Control)
  end

  def show
    @item = Gwqa::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    _show @item
  end

  def new
    @item = Gwqa::Control.new(
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
    )
    return error_auth unless @item.is_admin?
  end

  def create
    @item = Gwqa::Control.new(params[:item])
    return error_auth unless @item.is_admin?

    @item.left_index_use = '1'
    @item.upload_graphic_file_size_currently = 0
    @item.upload_document_file_size_currently = 0
    @item.categoey_view_line = 0
    @item.upload_system = 3

    _create @item, success_redirect_uri: "/gwfaq/controls"
  end

  def edit
    @item = Gwqa::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    @item.notification = 0 if @item.notification.blank?
  end

  def update
    @item = Gwqa::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    @item.attributes = params[:item]
    @item.categoey_view_line = 0

    _update @item, success_redirect_uri: "/gwfaq/controls"
  end

  def destroy
    @item = Gwqa::Control.find(params[:id])
    return error_auth unless @item.is_admin?

    _destroy @item, success_redirect_uri: "/gwfaq/controls"
  end

  private

  def load_control_items(model)
    items = model.distinct.where(view_hide: (params[:state] == "HIDE" ? 0 : 1))
    items = items.where(state: 'public').with_admin_role(Core.user) unless model.is_sysadm?
    items = items.order(sort_no: :asc, updated_at: :desc)
      .paginate(page: params[:page], per_page: params[:limit])
  end
end
