class Gwsub::Admin::Sb04::Sb04SettingsController  < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
  end

  def index
    init_params
    url_set
    return authentication_error(403) unless @u_role == true

    item = Gwsub::Sb04Setting.new
    item.and :type_name, "url"
    item.page   params[:page], params[:limit]
    @items = item.find(:all)
  end

  def show
    init_params
    url_set
    return authentication_error(403) unless @u_role == true

    @item = Gwsub::Sb04Setting.where(:id => params[:id]).first
  end

  def edit
    init_params
    url_set
    return authentication_error(403) unless @u_role == true

    @item = Gwsub::Sb04Setting.where(:id => params[:id]).first
  end
  def update
    init_params
    url_set
    return authentication_error(403) unless @u_role == true

    @item = Gwsub::Sb04Setting.where(:id => params[:id]).first

    if params[:item].present?
      @item.attributes = params[:item]
      location = "#{@public_uri}/#{@item.id}"
      options = {
        :success_redirect_uri=>location}
      _update(@item,options)
    else
      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb04stafflist.is_dev?(Core.user)
    @role_admin      = Gwsub::Sb04stafflist.is_admin?(Core.user)
    @u_role = @role_developer || @role_admin

    # 電子職員録 主管課権限設定
    # @role_sb04_dev  = Gwsub::Sb04stafflistviewMaster.is_sb04_dev?

    @menu_header3 = 'sb04_url_setting'
    @menu_title3  = 'URL設定'
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @public_uri = "/gwsub/sb04/09/sb04_settings/"
  end

  def url_set
    @l1_current = '07'
    @l2_current = '02'
    Page.title = "URL設定"
  end

end
