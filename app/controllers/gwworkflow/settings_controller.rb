class Gwworkflow::SettingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/gwworkflow"

  def pre_dispatch
    params[:title_id] = 1
    @title = Gwworkflow::Control.find(params[:title_id])

    Page.title = "ワークフロー 機能設定"
    @css = ["/_common/themes/gw/css/workflow.css"]
  end

  def index
  end

  def edit
    @item = load_notify_setting
  end

  def update
    @item = load_notify_setting
    @item.attributes = params[:item]
    _update @item
  end

  private

  def load_notify_setting
    Gwworkflow::Setting.where(unid: Core.user.id).first_or_create(notifying: 2)
  end
end
