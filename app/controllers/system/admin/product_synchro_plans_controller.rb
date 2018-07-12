class System::Admin::ProductSynchroPlansController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    return error_auth unless Core.user.has_role?('_admin/admin')

    @css = %w(/layout/admin/style.css)
    Page.title = "プロダクト同期"
  end

  def index
    @items = System::ProductSynchroPlan.order(start_at: :desc)
      .paginate(page: params[:page], per_page: 30)

    _index @items
  end

  def show
    @item = System::ProductSynchroPlan.find(params[:id])

    _show @item
  end

  def new
    @item = System::ProductSynchroPlan.new(
      :state => 'plan',
      :start_at => (Time.now + 1.days).strftime('%Y-%m-%d 00:00'),
      :product_ids => System::Product.all.pluck(:id)
    )
  end

  def create
    @item = System::ProductSynchroPlan.new(product_synchro)

    _create @item
  end

  def edit
    @item = System::ProductSynchroPlan.find(params[:id])
  end

  def update
    @item = System::ProductSynchroPlan.find(params[:id])
    @item.attributes = product_synchro

    _update @item
  end

  def destroy
    @item = System::ProductSynchroPlan.find(params[:id])

    _destroy @item
  end

private
  def product_synchro
    params.require(:item).permit(:start_at, :product_ids => [])
  end

end
