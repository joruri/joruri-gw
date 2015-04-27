class Gw::Admin::ConfigSettingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Model::DbnameAlias
  layout "admin/template/admin"

  def init_params
    Page.title = "設定"

    params[:limit] = nz(params[:limit],30)

    # 管理者設定　画面権限　（システム管理者）
    @admin_role = Gw.is_admin_admin?
    # 管理者設定　制限画面権限
    @editor_role  = Gw.is_editor?

    # 個別機能の、管理者・編集者権限
    # タブ編集
    @role_tabs  = Core.user.has_role?('edit_tab/editor')
    # 総務事務メッセージ編集
    @role_soumu_msg = Core.user.has_role?('pref_soumu_msg/editor')
    # ユーザー管理
    @role_users = Core.user.has_role?('system_users/editor')
    # 災害モード管理
    @role_disaster_admin_users = Gw::Property::PortalMode.is_disaster_admin?
    @role_disaster_editor_users = Gw::Property::PortalMode.is_disaster_editor?

    # ボード系管理者権限
    @role_bbs  = Gwbbs::Control.is_admin?
    @role_faq  = Gwfaq::Control.is_admin?
    @role_qa   = Gwqa::Control.is_admin?
    @role_doclibrary = Doclibrary::Control.is_admin?
    @role_digitallibrary = Digitallibrary::Control.is_admin?

    # この二つは、システム管理者のUIにのみ表示する
    # 回覧板
    @role_gwcircular = Gwcircular::Control.is_admin?
    # 照会回答
    @role_gwmonitor  = Gwmonitor::Control.is_sysadm?

    # アンケート集計システム
    @role_questionnaire = role_questionnaire

    #-------------------------------------------------------------------------------
    # 画面表示の制御用
    # 管理者設定　表示権限
    @is_gw_config_settings_roles  = Gw.is_admin_or_editor?
    @u_role = @is_gw_config_settings_roles

    # タブ表示権限
    # ポータルタブ表示
    @portal_editor = @role_tabs || @role_soumu_msg || @role_disaster_admin_users || @role_disaster_editor_users
    # 個人ポータル表示
    # 　システム管理者のみ
    # スケジューラー
    # 　システム管理者のみ
    # 会議等案内
    # 　システム管理者のみ
    # ボード系
    @role_board = @role_bbs ||  @role_faq ||  @role_qa  ||  @role_doclibrary  ||  @role_digitallibrary  ||  @role_gwcircular  ||  @role_gwmonitor
    @role_board2 = @role_bbs ||  @role_faq ||  @role_qa  ||  @role_doclibrary  ||  @role_digitallibrary
    # 基本設定タブ表示
    @base_editor   = @role_users
    # 削除設定
    # 　システム管理者のみ

    # HCS管理者権限
    @role_hcs_admin = Core.user.has_role?('hcs/admin')
    @role_hcs_portal = Core.user.has_role?('hcs_portal/admin')
    @role_hcs = @admin_role || @role_hcs_admin || @role_hcs_portal

    # 選択メニュー位置（管理者・編集者のみ）
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
    #@css = %w(/_common/themes/gw/css/admin.css)
    #@css = %w(/_common/themes/gw/css/portal_1column.css)

    qsa = ['c1' , 'c2']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

  def index
    init_params
  end

  def ind_settings
    init_params
  end

  def role_questionnaire
    #システムで登録されている管理者(システム管理者)ならtrueを返す
    Core.user.has_role?('enquete/admin')
  end

end
