class Gw::Admin::PropTypes::MessagesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  def pre_dispatch
    @parent = Gw::PropType.find_by(id: params[:prop_type_id]) || Gw::PropType.new.tap{|type| type.id = 0}
    @css = %w(/_common/themes/gw/css/prop_extra/schedule.css)
    Page.title = "#{@parent.name}　メッセージ編集"
    @sp_mode = :prop
    @is_gw_admin = Gw.is_admin_admin?
    return error_auth unless @is_gw_admin
  end

  def index
    @items = Gw::PropTypesMessage.where(type_id: @parent.id).order(:sort_no)
      .paginate(page: params[:page], per_page: params[:limit])
    _index @items
  end

  def show
    @item = Gw::PropTypesMessage.find(params[:id])
    _show @item
  end

  def new
    @item = Gw::PropTypesMessage.new(
      :type_id => @parent.id,
      :state => 1
    )
  end

  def create
    @item = Gw::PropTypesMessage.new(params[:item])
    @item.type_id = @parent.id
    _create @item
  end

  def edit
    @item = Gw::PropTypesMessage.find(params[:id])
    @item.type_id = @parent.id
  end

  def update
    @item = Gw::PropTypesMessage.find(params[:id])
    @item.type_id = @parent.id
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    @item = Gw::PropTypesMessage.find(params[:id])
    _destroy @item, :notice => "削除処理は完了しました。"
  end
end
