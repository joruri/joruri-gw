class Gw::Admin::PropTypes::UsersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  def pre_dispatch
    @parent = Gw::PropType.where(:id => params[:prop_type_id]).first
    return http_error(404) if @parent.blank?
    @css = %w(/_common/themes/gw/css/prop_extra/schedule.css)
    Page.title = "#{@parent.name}　制限参加者管理"
    @sp_mode = :prop
    @is_gw_admin = Gw.is_admin_admin?
    return error_auth unless @is_gw_admin
  end

  def index
    @items = Gw::PropTypesUser.where(type_id: @parent.id).order(:user_id)
      .paginate(page: params[:page], per_page: params[:limit])
    @user_item = Gw::PropTypesUser.new
    _index @items
  end

  def show
    @item = Gw::PropTypesUser.find(params[:id])
    _show @item
  end

  def new
    @item = Gw::PropTypesUser.new
    @item.prop_type_id = @parent.id
  end

  def create
    exist_check = System::User.where(:code => prop_users_params[:user_code])
    return redirect_to url_for(action: :index), notice: '指定のユーザーは登録できません。' if exist_check.present?

    @prop_type_user = System::User.new(
      :state => "enabled",
      :name => prop_users_params[:user_name],
      :name_en => prop_users_params[:user_code],
      :code => prop_users_params[:user_code],
      :ldap => 0
    )
    if @prop_type_user.save(validate: false)
      @item = Gw::PropTypesUser.new
      @item.user_id = @prop_type_user.id
      @item.type_id = @parent.id
      @item.save(validate: false)
    end
    redirect_to url_for(action: :index), notice: '追加処理が完了しました。'
  end

  def edit
    @item = Gw::PropTypesUser.find(params[:id])
    @item.type_id = @parent.id
  end

  def update
    @item = Gw::PropTypesUser.find(params[:id])
    @item.type_id = @parent.id
    @item.attributes = prop_users_params
    _update @item
  end

  def destroy
    @item = Gw::PropTypesUser.find(params[:id])
    @prop_user = System::User.where(:id => @item.user_id).first
    @prop_user.destroy unless @prop_user.blank?
    _destroy @item, :notice => "削除処理は完了しました。"
  end

private

  def prop_users_params
    params.permit(:user_name, :user_code)
  end

end
