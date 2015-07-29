# encoding: utf-8
class Gw::Admin::ConfigSettingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Model::DbnameAlias
  include Gwmonitor::Model::Database
  layout "admin/template/admin"

  def initialize_scaffold
  end

  def init_params
    Page.title = "設定"

    params[:limit] = nz(params[:limit],30)

    # 管理者設定　画面権限　（システム管理者）
    @admin_role = Gw.is_admin_admin?
    # 管理者設定　制限画面権限
    @editor_role  = Gw.is_editor?

    # 個別機能の、管理者・編集者権限
    # タブ編集
    @role_tabs  = System::Model::Role.get(1, Core.user.id ,'edit_tab', 'editor')
    # 総務事務メッセージ編集
    @role_soumu_msg = System::Model::Role.get(1, Core.user.id ,'pref_soumu_msg', 'editor')
    # ユーザー管理
    @role_users = System::Model::Role.get(1, Core.user.id ,'system_users','editor')
    # 災害モード管理
    @role_disaster_admin_users = Gw::AdminMode.is_disaster_admin?( Core.user.id )
    @role_disaster_editor_users = Gw::AdminMode.is_disaster_editor?( Core.user.id )

    # ボード系管理者権限
    # 掲示板
    @is_readable = nil
    params[:system]='gwbbs'
    admin_flags
    @role_bbs    =    @is_readable
    # 質問管理　FAQ
    @is_readable = nil
    params[:system]='gwfaq'
    admin_flags
    @role_faq   = @is_readable
    # 質問管理　QA
    @is_readable = nil
    params[:system]='gwqa'
    admin_flags
    @role_qa   = @is_readable
    # 書庫
    @is_readable = nil
    params[:system]='doclibrary'
    admin_flags
    @role_doclibrary    = @is_readable
    # 電子図書
    @is_readable = nil
    params[:system]='digitallibrary'
    admin_flags
    @role_digitallibrary    = @is_readable

    # この二つは、システム管理者のUIにのみ表示する
    # 回覧板
    @is_sysadm = nil
    @is_bbsadm = nil
    role_gwcircular('_menu')
    @role_gwcircular_sysadmin       = @is_sysadm
    @role_gwcircular_bbsadmin       = @is_bbsadm
    @role_gwcircular  = @role_gwcircular_sysadmin || @role_gwcircular_bbsadmin
    # 照会回答
    @is_sysadm = nil
    system_admin_flags
    @role_gwmonitor       = @is_sysadm

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
#    @role_hcs_admin = System::Model::Role.get(1, Core.user.id ,'hcs','admin')
#    @role_hcs_portal = System::Model::Role.get(1, Core.user.id ,'hcs_portal','admin')
#    @role_hcs = @admin_role || @role_hcs_admin || @role_hcs_portal

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

  def role_gwcircular(title_id = '_menu')
    # module Gwcircular::Model::DbnameAlias から、関数の内容をコピペ
    #システムで登録されている管理者(システム管理者)ならtrueを返す
    @is_sysadm = true if System::Model::Role.get(1, Core.user.id ,'gwcircular', 'admin')
    #自分の所属idがシステムで登録されている管理者(システム管理者)ならtrueを返す
    @is_sysadm = true if System::Model::Role.get(2, Core.user_group.id ,'gwcircular', 'admin') unless @is_sysadm
    #システム管理者なら回覧板管理者の資格も持つ
    @is_bbsadm = true if @is_sysadm

    #ここで回覧板管理ならシステム管理者なのでチェック不要
    unless @is_bbsadm
      #回覧板管理部門(回覧板毎に登録されている管理部門)に所属しているならtrueを返す
      item = Gwcircular::Adm.new
      item.and :user_id, 0
      item.and :group_code, Core.user_group.code
      #menuコントローラの時は、管理者に含まれているか確認するだけ(管理者リンクの表示・非表示判定だけ)なのでtitle_idを無視して取得する。
      item.and :title_id, title_id unless title_id == '_menu'
      items = item.find(:all)
      #レコードが返ってきたら回覧板管理者登録がある
      @is_bbsadm = true unless items.blank?

      unless @is_bbsadm
        #回覧板管理者(回覧板毎に登録されている管理者)ならtrueを返す
        item = Gwcircular::Adm.new
        item.and :user_code, Core.user.code
        item.and :group_code, Core.user_group.code
        #menuコントローラの時は、管理者に含まれているか確認するだけ(管理者リンクの表示・非表示判定だけ)なのでtitle_idを無視して取得する。
        item.and :title_id, title_id unless title_id == '_menu'
        items = item.find(:all)
        #レコードが返ってきたら回覧板管理者登録がある
        @is_bbsadm = true unless items.blank?
      end
    end
    #いずれかにヒットで管理者
    #細かい制御の為にシス管と回覧板管理は分けて持っておくことにする
    @is_admin = true if @is_sysadm
    @is_admin = true if @is_bbsadm
  end

  def role_questionnaire
    #システムで登録されている管理者(システム管理者)ならtrueを返す
    role_questionnaire_set = true if System::Model::Role.get(1, Core.user.id ,'enquete', 'admin')
    #自分の所属idがシステムで登録されている管理者(システム管理者)ならtrueを返す
    role_questionnaire_set = true if System::Model::Role.get(2, Core.user_group.id ,'enquete', 'admin') unless role_questionnaire_set
    return role_questionnaire_set
  end

end
