class Gwcircular::Admin::SettingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::Common
  layout "admin/template/gwcircular"

  def pre_dispatch
    params[:title_id] = 1
    @title = Gwcircular::Control.find(params[:title_id])

    Page.title = "回覧板 機能設定"
    @css = ["/_common/themes/gw/css/circular.css"]
    params[:limit] = @title.default_limit unless @title.default_limit.blank?
  end

  def index
  end
end
