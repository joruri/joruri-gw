class Gw::Admin::CountingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Model::DbnameAlias
  layout "admin/template/admin"

  def init_params
    Page.title = "設定"

    params[:limit] = nz(params[:limit],30)

    @admin_role = Gw.is_admin_admin?

    @editor_role  = Gw.is_editor?

    @role_tabs  = Core.user.has_role?('edit_tab/editor')

    @role_users = Core.user.has_role?('system_users/editor')

    @role_bbs  = Gwbbs::Control.is_admin?
    @role_faq  = Gwfaq::Control.is_admin?
    @role_qa   = Gwqa::Control.is_admin?
    @role_doclibrary     = Doclibrary::Control.is_admin?
    @role_digitallibrary = Digitallibrary::Control.is_admin?

    @role_gwcircular = Gwcircular::Control.is_admin?
    @role_gwmonitor  = Gwmonitor::Control.is_sysadm?

    @is_gw_config_settings_roles  = Gw.is_admin_or_editor?
    @u_role = @is_gw_config_settings_roles


    @portal_editor = @role_tabs

    @role_board = @role_bbs ||  @role_faq ||  @role_qa  ||  @role_doclibrary  ||  @role_digitallibrary  ||  @role_gwcircular  ||  @role_gwmonitor
    @role_board2 = @role_bbs ||  @role_faq ||  @role_qa  ||  @role_doclibrary  ||  @role_digitallibrary

    @base_editor   = @role_users

    if @admin_role==true
      params[:c1]  = nz(params[:c1],1)
      params[:c2]  = nz(params[:c2],1)
    else
      if @u_role==true
        params[:c1]  = nz(params[:c1],1)
        if @portal_editor == true
          params[:c2]  = nz(params[:c2],1)
        elsif @role_board2 == true
          params[:c2]  = nz(params[:c2],6)
        elsif @base_editor == true
          params[:c2]  = nz(params[:c2],5)
        else
          params[:c2]  = nz(params[:c2],1)
        end
      end
    end
    @css = %w(/layout/admin/style.css)

    return error_auth unless @admin_role
  end

  def index
    init_params
  end

  def memos
    init_params

    @set_counts = Gw::Property::MemoMobileMail.count
    @set1_counts = Gw::Property::MemoMobileMail.where("options like '%ktrans\":\"1%'").count
    @set2_counts = Gw::Property::MemoMobileMail.where("options like '%ktrans\":\"2%'").count
  end

  def mobiles
    init_params
    user_enabled = "state = 'enabled'"
    pass_enable = "mobile_password is not NULL"
    pass_disable = "mobile_password is NULL"
    access_enable = "mobile_access = 1"
    access_disable = "(mobile_access = 0 or mobile_access is null)"

    # [0]パスワード設定数, [1]許可数, [2]不許可数
    @m_pass_enable_counts = []
    @m_pass_enable_counts << System::User.where("#{user_enabled} and #{pass_enable}").count
    @m_pass_enable_counts << System::User.where("#{user_enabled} and #{pass_enable} and #{access_enable}").count
    @m_pass_enable_counts << System::User.where("#{user_enabled} and #{pass_enable} and #{access_disable}").count
    # [0]パスワード未設定数, [1]許可数, [2]不許可数
    @m_pass_disable_counts = []
    @m_pass_disable_counts << System::User.where("#{user_enabled} and #{pass_disable}").count
    @m_pass_disable_counts << System::User.where("#{user_enabled} and #{pass_disable} and #{access_enable}").count
    @m_pass_disable_counts << System::User.where("#{user_enabled} and #{pass_disable} and #{access_disable}").count
  end
end
