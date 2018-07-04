class Gw::Admin::PropOtherLimitsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  def pre_dispatch
    @css = %w(/_common/themes/gw/css/prop_extra/schedule.css)
    Page.title = "一般施設マスタ件数制限"

    @is_gw_admin = Gw.is_admin_admin?
    return error_auth unless @is_gw_admin

    @prop_types = Gw::PropType.where(state: "public").select(:id, :name).order(:sort_no, :id)
  end

  def index
    @items = Gw::PropOtherLimit.where(state: 'enabled').order(:sort_no)
      .paginate(page: params[:page], per_page: 20)
  end

  def show
    @item = Gw::PropOtherLimit.find(params[:id])
  end

  def new
    redirect_to "/gw/prop_other_limits", notice: "新規登録はできません。"
  end

  def create
    @item = Gw::PropOtherLimit.find(params[:id])
    @item.attributes = limit_params

    _update @item, success_redirect_uri: "/gw/prop_other_limits"
  end

  def edit
    @item = Gw::PropOtherLimit.find(params[:id])
  end

  def update
    @item = Gw::PropOtherLimit.find(params[:id])
    @item.attributes =limit_params

    _update @item, success_redirect_uri: "/gw/prop_other_limits/#{@item.id}"
  end

  def destroy
    @item = Gw::PropOtherLimit.find(params[:id])
    _destroy @item, success_redirect_uri: "/gw/prop_other_limits"
  end

  def synchro
    items = Gw::PropOtherLimit.update_all(state: 'disabled')
    groups = System::Group.where(state: 'enabled', level_no: 3).order(:sort_no)

    groups.each do |group|
      limit = Gw::PropOtherLimit.where(:gid => group.id).first
      if limit.blank?
        limit = Gw::PropOtherLimit.new
        limit.state = "enabled"
        limit.gid = group.id
        limit.sort_no = group.sort_no
        limit.limit = 20
      else
        limit.state = "enabled"
        limit.sort_no = group.sort_no
      end
      limit.save!
    end

    redirect_to "/gw/prop_other_limits/", notice: "同期処理は終了しました。"
  end

private
  def limit_params
    params.require(:item).permit(:gid, :limit)
  end

end
