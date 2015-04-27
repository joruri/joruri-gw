class Gw::Admin::SectionAdminMasterFuncNamesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    @u_role = Gw.is_admin_admin?
    return error_auth unless @u_role

    Page.title = '主管課マスタ 表示名設定'
  end

  def index
    @items = Gw::SectionAdminMasterFuncName.order(:sort_no)
      .paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = Gw::SectionAdminMasterFuncName.find(params[:id])
  end

  def new
    @item = Gw::SectionAdminMasterFuncName.new(:state => 'enabled')
  end

  def create
    @item = Gw::SectionAdminMasterFuncName.new(params[:item])

    _create @item
  end

  def edit
    @item = Gw::SectionAdminMasterFuncName.find(params[:id])
  end

  def update
    @item = Gw::SectionAdminMasterFuncName.find(params[:id])
    @item.attributes = params[:item]

    _update @item
  end

  def destroy
    @item = Gw::SectionAdminMasterFuncName.find(params[:id])
    @item.state       = 'deleted'
    @item.deleted_at  = Time.now
    @item.deleted_uid = Core.user.id
    @item.deleted_gid = Core.user_group.id
    Gw::SectionAdminMasterFuncName.record_timestamps = false # updated_atの更新を停止
    @item.save(:validate => false)
    Gw::SectionAdminMasterFuncName.record_timestamps = true  # updated_atの更新を再開

    redirect_to url_for(:action => :index)
  end
end
