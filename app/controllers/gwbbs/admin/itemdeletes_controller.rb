class Gwbbs::Admin::ItemdeletesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    check_gw_system_admin
    return error_auth unless @is_sysadm

    @css = ["/_common/themes/gw/css/bbs.css"]
    Page.title = "掲示板記事削除"
  end

  def url_options
    super.merge(params.slice(:page).symbolize_keys)
  end

  def index
  end

  def new
    @item = Gwbbs::Itemdelete.where(content_id: 0).first_or_create(admin_code: Core.user.code)
  end

  def create
    @item = Gwbbs::Itemdelete.where(content_id: 0).first
    @item.attributes = delete_params
    @item.admin_code = Core.user.code
    _create @item
  end

  def edit
    @items = Gwbbs::Control.order(:sort_no, :id).paginate(page: params[:page], per_page: 10)
  end

  def destroy
    del = 0
    title = Gwbbs::Control.find_by(id: params[:id])
    if title
      title.docs.where.not(state: 'preparation').where(["expiry_date < ?", Time.now]).find_each do |doc|
        del += 1 if doc.destroy
      end
    end
    redirect_to url_for(action: :edit), :notice => "#{del}件削除しました"
  end

protected

  def delete_params
    params.require(:item).permit(:limit_date)
  end

  def check_gw_system_admin
    @is_sysadm = Core.user.has_role?('_admin/admin')
    @is_bbsadm = true if @is_sysadm
  end
end
