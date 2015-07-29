# -*- encoding: utf-8 -*-
class Gwsub::Admin::Sb04::Sb0404menuController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  layout "admin/template/portal_1column"

  def initialize_scaffold
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    @page_title = "電子職員録 コード管理"
  end

  def index
    init_params
    if @u_role==true
    else
      if @role_sb04_dev==true
      else
        return authentication_error(403)
      end
    end
    @items = []
    @items << ['00期限設定','sb04_editable_dates']
    @items << ['10職名一覧','sb04officialtitles']
    @items << ['20所属一覧','sb04sections']
    @items << ['30担当一覧','sb04assignedjobs']
    @items << ['40職員一覧','sb04stafflists']
    @items << ['90座席表設定','sb04_seating_lists']
    _index @items
  end

  def init_params
    # ユーザー権限設定

    @role_developer  = Gwsub::Sb04stafflist.is_dev?(Core.user.id)
    @role_admin      = Gwsub::Sb04stafflist.is_admin?(Core.user.id)

    @u_role = @role_developer || @role_admin

    # 電子職員録 主管課権限設定
    @role_sb04_dev  = Gwsub::Sb04stafflistviewMaster.is_sb04_dev?

    @menu_header3 = 'sb0404menu'
    @menu_title3  = 'コード管理'

    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current = '05'
    @l2_current = '01'
    @l3_current = '01'
  end
end
