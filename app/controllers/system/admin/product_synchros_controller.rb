class System::Admin::ProductSynchrosController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def pre_dispatch
    return error_auth unless Core.user.has_role?('_admin/admin')

    @css = %w(/layout/admin/style.css)
    Page.title = "プロダクト同期"
  end

  def index
    @items = System::ProductSynchro.joins(:product)
      .where(:system_products => {:product_type => 'gw'}).order(:created_at => :desc)
      .paginate(page: params[:page], per_page: 30)

    _index @items
  end

  def show
    @item = System::ProductSynchro.find(params[:id])

    @items = System::ProductSynchro.where(:version => @item.version).order(:created_at, :id)
  end

  def new
    @item = System::ProductSynchro.new
  end

  def synchronize
    @item = System::ProductSynchro.new(synchro_params)
    @item = @item.execute

    flash[:notice] = 'プロダクト同期処理を開始しました。'
    redirect_to system_product_synchro_path(:id => @item.id)
  end

  def destroy
    @item = System::ProductSynchro.find(params[:id])

    System::ProductSynchro.delete_all(:version => @item.version)

    flash[:notice] = '削除処理が完了しました。'
    redirect_to :action => :index
  end

private
  def synchro_params
    params.require(:item).permit(:product_ids => [])
  end

end
