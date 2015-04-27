class Gw::Admin::ScheduleHelpConfigsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/schedule"

  def pre_dispatch
    @u_role = Gw.is_admin_admin?
    return error_auth unless @u_role

    @css = %w(/_common/themes/gw/css/schedule.css)
    Page.title = 'ヘルプリンク設定'
  end

  def index
    @item = Gw::Property::ScheduleHelpConfig.first_or_new
  end

  def update
    @item = Gw::Property::ScheduleHelpConfig.first_or_new
    @item.options_value = params[:item].values

    _update @item, :success_redirect_uri => "/gw/schedules/setting", :notice => "ヘルプリンク設定を更新しました。"
  end
end
